-- Enum
CREATE TYPE public.app_role AS ENUM ('lab_admin', 'staff');

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER LANGUAGE plpgsql SET search_path = public AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END; $$;

-- ===== profiles =====
CREATE TABLE public.profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name text,
  role text DEFAULT 'Lab Scientist',
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.profiles TO authenticated;
GRANT ALL ON public.profiles TO service_role;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- ===== user_roles =====
CREATE TABLE public.user_roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role public.app_role NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, role)
);
GRANT SELECT ON public.user_roles TO authenticated;
GRANT ALL ON public.user_roles TO service_role;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

-- ===== staff_permissions =====
CREATE TABLE public.staff_permissions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  permission text NOT NULL,
  granted_by uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, permission)
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.staff_permissions TO authenticated;
GRANT ALL ON public.staff_permissions TO service_role;
ALTER TABLE public.staff_permissions ENABLE ROW LEVEL SECURITY;

-- ===== helper functions =====
CREATE OR REPLACE FUNCTION public.has_role(_user_id uuid, _role public.app_role)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = _user_id AND role = _role)
$$;

CREATE OR REPLACE FUNCTION public.is_lab_admin(_user_id uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT public.has_role(_user_id, 'lab_admin')
$$;

CREATE OR REPLACE FUNCTION public.is_staff(_user_id uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = _user_id)
     AND COALESCE((SELECT active FROM public.profiles WHERE user_id = _user_id), true)
$$;

CREATE OR REPLACE FUNCTION public.is_senior_scientist(_user_id uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT public.is_lab_admin(_user_id) OR EXISTS (
    SELECT 1 FROM public.profiles WHERE user_id = _user_id AND active IS NOT FALSE AND lower(coalesce(role,'')) LIKE '%senior%')
$$;

CREATE OR REPLACE FUNCTION public.has_lab_permission(_user_id uuid, _permission text)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT public.is_lab_admin(_user_id) OR EXISTS (
    SELECT 1 FROM public.staff_permissions WHERE user_id = _user_id AND permission = _permission)
$$;

-- policies: profiles / roles / permissions
CREATE POLICY "Staff view profiles" ON public.profiles FOR SELECT TO authenticated
  USING (auth.uid() = user_id OR public.is_staff(auth.uid()));
CREATE POLICY "Users update own profile name" ON public.profiles FOR UPDATE TO authenticated
  USING (auth.uid() = user_id OR public.is_senior_scientist(auth.uid()))
  WITH CHECK (auth.uid() = user_id OR public.is_senior_scientist(auth.uid()));
CREATE POLICY "Seniors insert profiles" ON public.profiles FOR INSERT TO authenticated
  WITH CHECK (public.is_senior_scientist(auth.uid()));
CREATE POLICY "Admins delete profiles" ON public.profiles FOR DELETE TO authenticated
  USING (public.is_lab_admin(auth.uid()));

-- prevent non-seniors from changing their own job title / active flag
CREATE OR REPLACE FUNCTION public.protect_profile_role()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  IF auth.uid() IS NOT NULL AND NOT public.is_senior_scientist(auth.uid()) THEN
    NEW.role := OLD.role; NEW.active := OLD.active; NEW.user_id := OLD.user_id;
  END IF;
  RETURN NEW;
END; $$;
CREATE TRIGGER profiles_protect_role BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.protect_profile_role();
CREATE TRIGGER profiles_updated_at BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE POLICY "Users view own roles, admins view all" ON public.user_roles FOR SELECT TO authenticated
  USING (auth.uid() = user_id OR public.is_lab_admin(auth.uid()));

CREATE POLICY "Staff view permissions" ON public.staff_permissions FOR SELECT TO authenticated
  USING (auth.uid() = user_id OR public.is_lab_admin(auth.uid()));
CREATE POLICY "Admins manage permissions" ON public.staff_permissions FOR ALL TO authenticated
  USING (public.is_lab_admin(auth.uid())) WITH CHECK (public.is_lab_admin(auth.uid()));

-- every profile is a staff member
CREATE OR REPLACE FUNCTION public.grant_staff_role()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO public.user_roles (user_id, role) VALUES (NEW.user_id, 'staff') ON CONFLICT DO NOTHING;
  RETURN NEW;
END; $$;
CREATE TRIGGER profiles_grant_staff AFTER INSERT ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.grant_staff_role();

-- ===== scientists =====
CREATE TABLE public.scientists (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text,
  role text DEFAULT 'Lab Scientist',
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.scientists TO authenticated;
GRANT ALL ON public.scientists TO service_role;
ALTER TABLE public.scientists ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Staff view scientists" ON public.scientists FOR SELECT TO authenticated USING (public.is_staff(auth.uid()));
CREATE POLICY "Seniors manage scientists" ON public.scientists FOR ALL TO authenticated
  USING (public.is_senior_scientist(auth.uid())) WITH CHECK (public.is_senior_scientist(auth.uid()));

-- ===== test_categories =====
CREATE TABLE public.test_categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  description text,
  sort_order integer NOT NULL DEFAULT 0,
  active boolean NOT NULL DEFAULT true,
  created_by uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.test_categories TO authenticated;
GRANT ALL ON public.test_categories TO service_role;
ALTER TABLE public.test_categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Staff view categories" ON public.test_categories FOR SELECT TO authenticated USING (public.is_staff(auth.uid()));
CREATE POLICY "Admins manage categories" ON public.test_categories FOR ALL TO authenticated
  USING (public.is_lab_admin(auth.uid())) WITH CHECK (public.is_lab_admin(auth.uid()));
CREATE TRIGGER test_categories_updated_at BEFORE UPDATE ON public.test_categories
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ===== lab_tests =====
CREATE TABLE public.lab_tests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  category_id uuid REFERENCES public.test_categories(id) ON DELETE SET NULL,
  code text,
  input_type text NOT NULL DEFAULT 'text',
  unit text,
  reference_range text,
  description text,
  options text[] NOT NULL DEFAULT '{}',
  result_fields jsonb NOT NULL DEFAULT '[]'::jsonb,
  active boolean NOT NULL DEFAULT true,
  sort_order integer NOT NULL DEFAULT 0,
  created_by uuid,
  updated_by uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.lab_tests TO authenticated;
GRANT ALL ON public.lab_tests TO service_role;
ALTER TABLE public.lab_tests ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Staff view lab tests" ON public.lab_tests FOR SELECT TO authenticated USING (public.is_staff(auth.uid()));
CREATE POLICY "Admins manage lab tests" ON public.lab_tests FOR ALL TO authenticated
  USING (public.is_lab_admin(auth.uid())) WITH CHECK (public.is_lab_admin(auth.uid()));
CREATE TRIGGER lab_tests_updated_at BEFORE UPDATE ON public.lab_tests
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ===== test_forms =====
CREATE TABLE public.test_forms (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  serial text NOT NULL UNIQUE,
  patient_name text NOT NULL,
  age integer NOT NULL DEFAULT 0,
  gender text NOT NULL DEFAULT 'Male',
  phone text,
  email text,
  referred_by text,
  doctor_phone text,
  institution text,
  date_collected date NOT NULL DEFAULT CURRENT_DATE,
  nature_of_specimen text,
  examination_required text,
  tests_requested text[] NOT NULL DEFAULT '{}',
  clinical_notes text,
  bill text DEFAULT 'Patient',
  status text DEFAULT 'Pending',
  approval_status text NOT NULL DEFAULT 'Pending Review',
  results jsonb DEFAULT '{}'::jsonb,
  scientist_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  submitted_by uuid,
  submitted_at timestamptz,
  approved_by uuid,
  approved_at timestamptz,
  rejected_by uuid,
  rejected_at timestamptz,
  rejection_reason text,
  last_edited_by uuid,
  completed_at timestamptz,
  created_by uuid,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);
CREATE INDEX test_forms_status_idx ON public.test_forms(status);
CREATE INDEX test_forms_created_at_idx ON public.test_forms(created_at DESC);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.test_forms TO authenticated;
GRANT ALL ON public.test_forms TO service_role;
ALTER TABLE public.test_forms ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Staff view forms" ON public.test_forms FOR SELECT TO authenticated USING (public.is_staff(auth.uid()));
CREATE POLICY "Staff create forms" ON public.test_forms FOR INSERT TO authenticated WITH CHECK (public.is_staff(auth.uid()));
CREATE POLICY "Staff update forms" ON public.test_forms FOR UPDATE TO authenticated
  USING (public.is_staff(auth.uid()) AND (approval_status IS DISTINCT FROM 'Approved' OR public.is_senior_scientist(auth.uid())))
  WITH CHECK (public.is_staff(auth.uid()));
CREATE POLICY "Admins delete forms" ON public.test_forms FOR DELETE TO authenticated USING (public.is_lab_admin(auth.uid()));
CREATE TRIGGER test_forms_updated_at BEFORE UPDATE ON public.test_forms
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- only seniors/admins may set approval
CREATE OR REPLACE FUNCTION public.protect_form_approval()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  IF auth.uid() IS NOT NULL AND NOT public.is_senior_scientist(auth.uid()) THEN
    IF NEW.approval_status IS DISTINCT FROM OLD.approval_status
       OR NEW.approved_by IS DISTINCT FROM OLD.approved_by THEN
      RAISE EXCEPTION 'Only a Senior Scientist or Lab Admin can approve results';
    END IF;
  END IF;
  RETURN NEW;
END; $$;
CREATE TRIGGER test_forms_protect_approval BEFORE UPDATE ON public.test_forms
  FOR EACH ROW EXECUTE FUNCTION public.protect_form_approval();

-- ===== result_audit_log =====
CREATE TABLE public.result_audit_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  form_id uuid REFERENCES public.test_forms(id) ON DELETE SET NULL,
  serial text,
  action text NOT NULL,
  field_key text,
  field_label text,
  old_value text,
  new_value text,
  reason text,
  changed_by uuid,
  changed_by_name text,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT ON public.result_audit_log TO authenticated;
GRANT ALL ON public.result_audit_log TO service_role;
ALTER TABLE public.result_audit_log ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Staff view audit" ON public.result_audit_log FOR SELECT TO authenticated USING (public.is_staff(auth.uid()));
CREATE POLICY "Staff write own audit" ON public.result_audit_log FOR INSERT TO authenticated
  WITH CHECK (public.is_staff(auth.uid()) AND changed_by = auth.uid());

-- ===== scans =====
CREATE TABLE public.scan_patients (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  mrn text NOT NULL UNIQUE,
  full_name text NOT NULL,
  age integer,
  gender text,
  phone text,
  email text,
  address text,
  notes text,
  primary_doctor text,
  doctor_phone text,
  created_by uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE public.scans (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  serial text NOT NULL UNIQUE,
  patient_id uuid NOT NULL REFERENCES public.scan_patients(id) ON DELETE CASCADE,
  scan_type text NOT NULL,
  modality text,
  body_part text,
  scan_date timestamptz NOT NULL DEFAULT now(),
  status text NOT NULL DEFAULT 'Pending',
  urgent boolean NOT NULL DEFAULT false,
  clinical_indication text,
  referring_doctor text,
  findings text,
  impression text,
  recommendation text,
  report_text text,
  reported_by uuid,
  reported_at timestamptz,
  approved_by uuid,
  approved_at timestamptz,
  created_by uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE public.scan_images (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  scan_id uuid NOT NULL REFERENCES public.scans(id) ON DELETE CASCADE,
  storage_path text NOT NULL,
  caption text,
  sort_order integer NOT NULL DEFAULT 0,
  uploaded_by uuid,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE public.scan_appointments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id uuid REFERENCES public.scan_patients(id) ON DELETE SET NULL,
  patient_name text NOT NULL,
  patient_phone text,
  scan_type text NOT NULL,
  scheduled_at timestamptz NOT NULL,
  status text NOT NULL DEFAULT 'Scheduled',
  notes text,
  created_by uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE public.scan_activity (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  scan_id uuid REFERENCES public.scans(id) ON DELETE CASCADE,
  user_id uuid,
  user_name text,
  action text NOT NULL,
  details text,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.scan_patients, public.scans, public.scan_images, public.scan_appointments TO authenticated;
GRANT SELECT, INSERT ON public.scan_activity TO authenticated;
GRANT ALL ON public.scan_patients, public.scans, public.scan_images, public.scan_appointments, public.scan_activity TO service_role;
ALTER TABLE public.scan_patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scan_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scan_appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scan_activity ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Staff view scan patients" ON public.scan_patients FOR SELECT TO authenticated USING (public.is_staff(auth.uid()));
CREATE POLICY "Staff add scan patients" ON public.scan_patients FOR INSERT TO authenticated WITH CHECK (public.is_staff(auth.uid()));
CREATE POLICY "Staff edit scan patients" ON public.scan_patients FOR UPDATE TO authenticated USING (public.is_staff(auth.uid())) WITH CHECK (public.is_staff(auth.uid()));
CREATE POLICY "Admins delete scan patients" ON public.scan_patients FOR DELETE TO authenticated USING (public.is_lab_admin(auth.uid()));

CREATE POLICY "Staff view scans" ON public.scans FOR SELECT TO authenticated USING (public.is_staff(auth.uid()));
CREATE POLICY "Staff add scans" ON public.scans FOR INSERT TO authenticated WITH CHECK (public.is_staff(auth.uid()));
CREATE POLICY "Staff edit scans" ON public.scans FOR UPDATE TO authenticated USING (public.is_staff(auth.uid())) WITH CHECK (public.is_staff(auth.uid()));
CREATE POLICY "Admins delete scans" ON public.scans FOR DELETE TO authenticated USING (public.is_lab_admin(auth.uid()));

CREATE POLICY "Staff view scan images" ON public.scan_images FOR SELECT TO authenticated USING (public.is_staff(auth.uid()));
CREATE POLICY "Staff add scan images" ON public.scan_images FOR INSERT TO authenticated WITH CHECK (public.is_staff(auth.uid()));
CREATE POLICY "Staff edit scan images" ON public.scan_images FOR UPDATE TO authenticated USING (public.is_staff(auth.uid())) WITH CHECK (public.is_staff(auth.uid()));
CREATE POLICY "Staff delete scan images" ON public.scan_images FOR DELETE TO authenticated USING (public.is_staff(auth.uid()));

CREATE POLICY "Staff view appointments" ON public.scan_appointments FOR SELECT TO authenticated USING (public.is_staff(auth.uid()));
CREATE POLICY "Staff add appointments" ON public.scan_appointments FOR INSERT TO authenticated WITH CHECK (public.is_staff(auth.uid()));
CREATE POLICY "Staff edit appointments" ON public.scan_appointments FOR UPDATE TO authenticated USING (public.is_staff(auth.uid())) WITH CHECK (public.is_staff(auth.uid()));
CREATE POLICY "Staff delete appointments" ON public.scan_appointments FOR DELETE TO authenticated USING (public.is_staff(auth.uid()));

CREATE POLICY "Staff view scan activity" ON public.scan_activity FOR SELECT TO authenticated USING (public.is_staff(auth.uid()));
CREATE POLICY "Staff log scan activity" ON public.scan_activity FOR INSERT TO authenticated WITH CHECK (public.is_staff(auth.uid()));

CREATE TRIGGER scan_patients_updated_at BEFORE UPDATE ON public.scan_patients FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER scans_updated_at BEFORE UPDATE ON public.scans FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER scan_appointments_updated_at BEFORE UPDATE ON public.scan_appointments FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ===== shop / pharmacy =====
CREATE TABLE public.products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  category text NOT NULL,
  uses text,
  description text,
  image_url text,
  price numeric,
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE public.pharmacy_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  category text NOT NULL,
  uses text,
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.products, public.pharmacy_items TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.products, public.pharmacy_items TO authenticated;
GRANT ALL ON public.products, public.pharmacy_items TO service_role;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pharmacy_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public view active products" ON public.products FOR SELECT TO anon, authenticated
  USING (active OR public.is_staff(auth.uid()));
CREATE POLICY "Seniors manage products" ON public.products FOR ALL TO authenticated
  USING (public.is_senior_scientist(auth.uid())) WITH CHECK (public.is_senior_scientist(auth.uid()));
CREATE POLICY "Public view active pharmacy" ON public.pharmacy_items FOR SELECT TO anon, authenticated
  USING (active OR public.is_staff(auth.uid()));
CREATE POLICY "Seniors manage pharmacy" ON public.pharmacy_items FOR ALL TO authenticated
  USING (public.is_senior_scientist(auth.uid())) WITH CHECK (public.is_senior_scientist(auth.uid()));
CREATE TRIGGER products_updated_at BEFORE UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER pharmacy_updated_at BEFORE UPDATE ON public.pharmacy_items FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ===== public lookup functions =====
CREATE OR REPLACE FUNCTION public.get_public_result(_serial text)
RETURNS TABLE (serial text, patient_name text, age integer, gender text, date_collected date,
  referred_by text, nature_of_specimen text, examination_required text, tests_requested text[],
  results jsonb, status text, completed_at timestamptz, scientist_name text)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT f.serial, f.patient_name, f.age, f.gender, f.date_collected, f.referred_by,
    f.nature_of_specimen, f.examination_required, f.tests_requested, f.results, f.status,
    f.completed_at, p.display_name
  FROM public.test_forms f
  LEFT JOIN public.profiles p ON p.id = f.scientist_id
  WHERE upper(f.serial) = upper(trim(_serial)) AND f.status = 'Completed'
  LIMIT 1
$$;

CREATE OR REPLACE FUNCTION public.get_public_scan(_serial text)
RETURNS TABLE (serial text, patient_name text, mrn text, age integer, gender text, phone text,
  primary_doctor text, scan_type text, modality text, body_part text, scan_date timestamptz,
  status text, urgent boolean, clinical_indication text, referring_doctor text, findings text,
  impression text, recommendation text, report_text text, reported_at timestamptz,
  approved_at timestamptz, reporter_name text, approver_name text)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT s.serial, sp.full_name, sp.mrn, sp.age, sp.gender, sp.phone, sp.primary_doctor,
    s.scan_type, s.modality, s.body_part, s.scan_date, s.status, s.urgent, s.clinical_indication,
    s.referring_doctor, s.findings, s.impression, s.recommendation, s.report_text, s.reported_at,
    s.approved_at, rp.display_name, ap.display_name
  FROM public.scans s
  JOIN public.scan_patients sp ON sp.id = s.patient_id
  LEFT JOIN public.profiles rp ON rp.user_id = s.reported_by
  LEFT JOIN public.profiles ap ON ap.user_id = s.approved_by
  WHERE upper(s.serial) = upper(trim(_serial)) AND s.status IN ('Approved','Completed')
  LIMIT 1
$$;
GRANT EXECUTE ON FUNCTION public.get_public_result(text) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_public_scan(text) TO anon, authenticated;

-- ===== realtime =====
ALTER PUBLICATION supabase_realtime ADD TABLE public.test_forms;
ALTER PUBLICATION supabase_realtime ADD TABLE public.scans;
ALTER PUBLICATION supabase_realtime ADD TABLE public.scan_appointments;
ALTER PUBLICATION supabase_realtime ADD TABLE public.scan_activity;
ALTER PUBLICATION supabase_realtime ADD TABLE public.lab_tests;

-- ===== seed catalog =====
INSERT INTO public.test_categories (name, sort_order) VALUES
  ('Hematology', 1), ('Chemical Pathology', 2), ('Medical Microbiology', 3);

INSERT INTO public.lab_tests (name, category_id, sort_order)
SELECT t.name, c.id, t.ord
FROM (VALUES
  ('Hematology','Full Blood Count (FBC)',1),('Hematology','Packed Cell Volume (PCV)',2),('Hematology','Blood Group',3),
  ('Hematology','Genotype',4),('Hematology','Platelet Count',5),('Hematology','Prothrombin Time',6),
  ('Hematology','Bleeding Time',7),('Hematology','Clotting Time',8),('Hematology','Hepatitis Screening',9),
  ('Hematology','Retroviral Screening (HIV 1&2)',10),('Hematology','Syphilis Screening (VDRL)',11),('Hematology','Pregnancy Test',12),
  ('Chemical Pathology','Fasting Blood Sugar',101),('Chemical Pathology','Random Blood Sugar',102),('Chemical Pathology','Liver Function Test',103),
  ('Chemical Pathology','Kidney Function Test',104),('Chemical Pathology','Lipid Profile Test',105),('Chemical Pathology','Calcium Test',106),
  ('Chemical Pathology','Uric Acid Test',107),('Chemical Pathology','Bicarbonate Test',108),('Chemical Pathology','Female Hormone Profile',109),
  ('Chemical Pathology','Male Hormone Profile',110),('Chemical Pathology','Luteinizing Hormone (LH)',111),('Chemical Pathology','Follicle Stimulating Hormone (FSH)',112),
  ('Chemical Pathology','Prolactin',113),('Chemical Pathology','Progesterone',114),('Chemical Pathology','Estradiol (E2)',115),
  ('Chemical Pathology','Testosterone',116),('Chemical Pathology','Thyroid Function test',117),('Chemical Pathology','HbA1c',118),
  ('Medical Microbiology','Malaria Test',201),('Medical Microbiology','Widal Test',202),('Medical Microbiology','Urine Microscopy',203),
  ('Medical Microbiology','Urine Culture',204),('Medical Microbiology','High Vaginal Swab (HVS)/Endocervical Swab (ECS)',205),('Medical Microbiology','Urethral Swab',206),
  ('Medical Microbiology','Stool Analysis',207),('Medical Microbiology','Stool Culture',208),('Medical Microbiology','Sputum Culture',209),
  ('Medical Microbiology','Semen Analysis',210),('Medical Microbiology','Helicobacter Pylori',211),('Medical Microbiology','Fecal Occult Blood',212),
  ('Medical Microbiology','Microfilaria',213),('Medical Microbiology','Semen Culture',214),('Medical Microbiology','Urine Analysis',215),
  ('Medical Microbiology','Eye Swab',216),('Medical Microbiology','Wound Swab',217),('Medical Microbiology','Ear Swab',218)
) AS t(cat, name, ord)
JOIN public.test_categories c ON c.name = t.cat;