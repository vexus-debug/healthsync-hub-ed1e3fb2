import { useState } from "react";
import { Link } from "@/lib/router-compat";
import { SEO } from "@/components/seo/SEO";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Layout } from "@/components/layout/Layout";
import { Reveal } from "@/components/Reveal";
import {
  ShieldCheck, Microscope, Truck, Mail, Clock, Award,
  FlaskConical, HeartPulse, Pill, Stethoscope, ArrowRight, Phone, MessageCircle, MapPin,
  Search, CalendarCheck, FlaskRound, FileText, Download, Home, BadgeCheck, Sparkles, Activity, Baby, TestTube
} from "lucide-react";
import heroImg from "@/assets/hero-lab.jpg";
import bloodImg from "@/assets/blood-test.jpg";
import nurseImg from "@/assets/nurse.jpg";
import sampleImg from "@/assets/sample.jpg";
import consultImg from "@/assets/consultation.jpg";
import { SITE, buildWhatsAppLink } from "@/lib/site";

const popularTests = [
  {
    icon: FlaskConical,
    code: "HAE-001",
    title: "Full Blood Count (FBC)",
    category: "Haematology",
    sample: "EDTA whole blood",
    fasting: false,
    tat: "Same day",
    parameters: 22,
  },
  {
    icon: HeartPulse,
    code: "CHE-204",
    title: "Lipid Profile & HbA1c",
    category: "Clinical Chemistry",
    sample: "Serum",
    fasting: true,
    tat: "24 hours",
    parameters: 8,
  },
  {
    icon: ShieldCheck,
    code: "SER-118",
    title: "HIV I & II + Hepatitis B / C",
    category: "Serology",
    sample: "Serum",
    fasting: false,
    tat: "Same day",
    parameters: 4,
  },
  {
    icon: Activity,
    code: "END-307",
    title: "Thyroid Function (TSH, T3, T4)",
    category: "Endocrinology",
    sample: "Serum",
    fasting: false,
    tat: "48 hours",
    parameters: 3,
  },
  {
    icon: Baby,
    code: "REP-411",
    title: "Seminal Fluid Analysis",
    category: "Reproductive Health",
    sample: "Semen",
    fasting: false,
    tat: "24 hours",
    parameters: 12,
  },
  {
    icon: TestTube,
    code: "PAR-052",
    title: "Malaria Parasite & Widal",
    category: "Parasitology",
    sample: "Whole blood",
    fasting: false,
    tat: "Same day",
    parameters: 2,
  },
];

const testCategories = [
  "All tests",
  "Haematology",
  "Clinical Chemistry",
  "Serology",
  "Endocrinology",
  "Reproductive Health",
  "Parasitology",
];

const trust = [
  { icon: BadgeCheck, label: "Licensed Lab" },
  { icon: ShieldCheck, label: "100% Confidential" },
  { icon: Award, label: "Qualified Clinicians" },
  { icon: Sparkles, label: "Modern Equipment" },
];

const steps = [
  {
    n: "01",
    icon: Search,
    title: "Select your test",
    desc: "Browse our catalogue of 200+ tests or speak with a clinician to identify the appropriate panel.",
    meta: "5–10 min consult",
  },
  {
    n: "02",
    icon: CalendarCheck,
    title: "Book your appointment",
    desc: "Schedule online, walk in during clinic hours, or request a confidential home sample collection.",
    meta: "Same-day slots available",
  },
  {
    n: "03",
    icon: FlaskRound,
    title: "Sample collection & analysis",
    desc: "Samples are collected by certified phlebotomists and processed by qualified medical scientists.",
    meta: "Chain-of-custody tracked",
  },
  {
    n: "04",
    icon: FileText,
    title: "Verified results delivered",
    desc: "Reports are reviewed and signed by a consultant before secure delivery via email, WhatsApp or in-person.",
    meta: "Avg. turnaround: 24 hrs",
  },
];

const Index = () => {
  const [category, setCategory] = useState("All tests");
  const visibleTests = category === "All tests" ? popularTests : popularTests.filter((t) => t.category === category);
  return (
    <Layout>
      <SEO
        title="Green Medical Diagnostics — Confidential Medical Laboratory in Port Harcourt"
        description="MLSCN-licensed medical laboratory in Elioprawo Road, Port Harcourt offering confidential lab tests, consultations, pharmacy and home sample collection. Your Health. Your Privacy. Your Choice."
        keywords="medical laboratory Port Harcourt, lab tests Rivers State, confidential lab Nigeria, blood test Port Harcourt, home sample collection, Green Medical Diagnostics"
      />
      {/* 1. HERO — editorial quiet-luxury split */}
      <section className="relative bg-background">
        <div className="container pt-6 pb-10 md:pt-12 lg:pt-14">
          <div className="grid lg:grid-cols-12 gap-10 lg:gap-14 items-stretch">
            <div className="lg:col-span-7 flex flex-col justify-center space-y-8 animate-fade-up">
              <div className="flex flex-wrap items-center gap-x-4 gap-y-2 font-mono text-[11px] uppercase tracking-[0.22em] text-muted-foreground">
                <span className="inline-flex items-center gap-2 text-primary">
                  <BadgeCheck className="h-3.5 w-3.5" /> Licensed Laboratory
                </span>
                <span className="h-px w-6 bg-border" />
                <span>Confidential Care</span>
              </div>

              <h1 className="font-display text-[2.6rem] leading-[1.02] sm:text-6xl lg:text-7xl font-semibold tracking-tight text-foreground">
                Where clinical precision
                <br className="hidden sm:block" /> meets{" "}
                <span className="italic font-light text-primary">quiet dignity.</span>
              </h1>

              <p className="max-w-xl text-base md:text-lg leading-relaxed text-muted-foreground">
                A private medical laboratory in Port Harcourt for accurate, unhurried and confidential care — verified blood tests, consultations and home sample collection.
              </p>

              <div className="flex flex-wrap items-center gap-x-8 gap-y-4">
                <Button asChild size="lg" className="rounded-full px-7 font-medium">
                  <Link to="/book">Book a private appointment</Link>
                </Button>
                <a
                  href={buildWhatsAppLink("Hello Green Medical, I'd like to request home sample collection.")}
                  target="_blank"
                  rel="noreferrer"
                  className="group inline-flex items-center gap-2 text-sm font-medium text-foreground border-b border-foreground/30 pb-0.5 hover:border-primary hover:text-primary transition-colors"
                >
                  Request home pickup
                  <ArrowRight className="h-4 w-4 transition-transform group-hover:translate-x-1" />
                </a>
              </div>

              <div className="flex flex-wrap items-center gap-x-6 gap-y-2 text-sm text-muted-foreground">
                <span className="inline-flex items-center gap-2">
                  <span className="h-1.5 w-1.5 rounded-full bg-success animate-pulse" /> Walk-ins welcome today
                </span>
                <a href={`tel:${SITE.phones[0].replace(/\s/g, "")}`} className="inline-flex items-center gap-2 hover:text-foreground">
                  <Phone className="h-3.5 w-3.5" /> {SITE.phones[0]}
                </a>
              </div>
            </div>

            <figure className="lg:col-span-5 animate-fade-in">
              <div className="relative overflow-hidden rounded-2xl border border-border/60 aspect-[4/5]">
                <img src={consultImg} alt="Clinician reviewing a patient's results in a private consultation" className="h-full w-full object-cover" />
                <div className="absolute left-4 bottom-4 right-4 flex items-end justify-between gap-3">
                  <div className="rounded-lg bg-background/90 backdrop-blur px-3 py-2 font-mono text-[10px] uppercase tracking-[0.18em] text-foreground">
                    <p className="text-muted-foreground">Ref · GMD-PH</p>
                    <p className="mt-0.5 inline-flex items-center gap-1"><MapPin className="h-3 w-3" /> Elioprawo Rd, PH</p>
                  </div>
                </div>
              </div>
              <figcaption className="mt-4 font-display italic text-sm text-muted-foreground">
                “Every sample handled with a private, barcoded chain of custody.”
              </figcaption>
            </figure>
          </div>

          <div className="mt-14 md:mt-20 grid grid-cols-3 border-y border-border">
            {[
              { n: "01", k: "200+", v: "Diagnostic tests" },
              { n: "02", k: "24 hr", v: "Average turnaround" },
              { n: "03", k: "100%", v: "Confidential reports" },
            ].map((s, i) => (
              <div key={s.n} className={`flex min-w-0 flex-col gap-1 px-2 py-4 sm:flex-row sm:items-baseline sm:gap-4 sm:px-6 sm:py-5 ${i > 0 ? "border-l border-border" : ""}`}>
                <span className="font-mono text-[11px] text-muted-foreground">{s.n}</span>
                <span className="font-display text-xl sm:text-2xl font-semibold text-foreground">{s.k}</span>
                <span className="text-xs sm:text-sm text-muted-foreground leading-tight">{s.v}</span>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* 2. HOW IT WORKS — clinical process */}
      <section className="relative py-20 md:py-28 bg-primary text-primary-foreground">
        <div className="container">
          <div className="grid lg:grid-cols-12 gap-12 lg:gap-16">
            {/* Left column: section intro */}
            <Reveal variant="right" className="lg:col-span-4 lg:sticky lg:top-28 self-start space-y-6">
              <div className="flex items-center gap-3 text-xs uppercase tracking-[0.22em] text-primary-foreground/80 font-semibold">
                <span className="h-px w-8 bg-primary-foreground/60" />
                The Process
              </div>
              <h2 className="font-display text-3xl md:text-4xl font-bold leading-tight tracking-tight">
                A standardised pathway from request to verified report.
              </h2>
              <p className="text-primary-foreground/75 leading-relaxed">
                Every sample at Green Medical Diagnostics follows a documented, ISO-aligned workflow — handled by qualified medical scientists and reviewed by consultant pathologists before release.
              </p>
              <div className="flex flex-wrap items-center gap-2 pt-2">
                <span className="inline-flex items-center gap-2 px-3 py-1.5 rounded-md bg-primary-foreground/10 border border-primary-foreground/20 text-primary-foreground text-xs font-semibold">
                  <BadgeCheck className="h-3.5 w-3.5" /> Quality assured
                </span>
                <span className="inline-flex items-center gap-2 px-3 py-1.5 rounded-md bg-primary-foreground/10 border border-primary-foreground/20 text-primary-foreground text-xs font-semibold">
                  <ShieldCheck className="h-3.5 w-3.5" /> Confidential
                </span>
              </div>
              <div className="pt-4">
                <Button asChild size="lg" className="bg-background text-primary hover:bg-background/90">
                  <Link to="/book">Begin your test request <ArrowRight className="h-4 w-4" /></Link>
                </Button>
              </div>
            </Reveal>

            {/* Right column: numbered process list */}
            <ol className="lg:col-span-8 relative">
              <div className="absolute left-[27px] top-2 bottom-2 w-px bg-primary-foreground/25" aria-hidden="true" />
              {steps.map((s, i) => (
                <Reveal as="li" key={s.n} variant="left" delay={i * 90} className="relative group pl-20 pr-2 py-6 md:py-7 border-b border-primary-foreground/15 last:border-b-0 block">
                  {/* Step number marker */}
                  <div className="absolute left-0 top-6 md:top-7 flex flex-col items-center">
                    <div className="relative h-14 w-14 rounded-full bg-primary-foreground/10 border border-primary-foreground/30 grid place-items-center group-hover:border-primary-foreground transition-smooth">
                      <s.icon className="h-5 w-5 text-primary-foreground" />
                      <span className="absolute -top-1 -right-1 h-5 min-w-5 px-1 rounded-full bg-background text-primary text-[10px] font-bold grid place-items-center font-mono">
                        {s.n}
                      </span>
                    </div>
                  </div>

                  <div className="flex flex-col md:flex-row md:items-baseline md:justify-between gap-1 md:gap-6">
                    <div className="flex-1">
                      <p className="font-mono text-[11px] uppercase tracking-[0.18em] text-primary-foreground/75 mb-1.5">
                        Step {s.n} {i < steps.length - 1 && "→"}
                      </p>
                      <h3 className="font-display font-bold text-lg md:text-xl text-primary-foreground">
                        {s.title}
                      </h3>
                      <p className="mt-2 text-sm md:text-[15px] text-primary-foreground/75 leading-relaxed max-w-xl">
                        {s.desc}
                      </p>
                    </div>
                    <div className="shrink-0 inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md bg-primary-foreground/10 border border-primary-foreground/20 text-primary-foreground text-[11px] font-mono font-semibold whitespace-nowrap self-start">
                      <Clock className="h-3 w-3" />
                      {s.meta}
                    </div>
                  </div>
                </Reveal>
              ))}
            </ol>
          </div>
        </div>
      </section>

      {/* 3. CLINICAL GOVERNANCE & STANDARDS */}
      <section className="py-20 md:py-28 border-y border-border/60 bg-background">
        <div className="container grid lg:grid-cols-12 gap-12 lg:gap-16">
          <Reveal variant="up" className="lg:col-span-5 space-y-6">
            <p className="font-mono text-xs tracking-[0.2em] text-primary">[ 01 ] WHY PATIENTS TRUST US</p>
            <h2 className="font-display text-3xl md:text-5xl font-bold leading-[1.05] tracking-tight text-foreground text-balance">
              Results you and your doctor can rely on.
            </h2>
            <p className="font-mono text-xs tracking-wider text-muted-foreground border-l-2 border-primary pl-4">
              LICENSED BY THE MEDICAL LABORATORY SCIENCE COUNCIL OF NIGERIA
            </p>
            <p className="text-muted-foreground leading-relaxed max-w-md">
              Every test is checked by experienced lab doctors. Nothing is sent to you until it has been double-checked for accuracy.
            </p>
            <div className="flex flex-wrap gap-3 pt-2">
              <Button asChild size="lg" className="rounded-none"><Link to="/about">About the Lab</Link></Button>
              <Button asChild variant="outline" size="lg" className="rounded-none"><Link to="/services">Our Tests</Link></Button>
            </div>
          </Reveal>
          <ol className="lg:col-span-7 border-t border-border">
            {[
              { t: "Fully licensed", d: "We follow national lab standards and are regularly inspected." },
              { t: "Your privacy comes first", d: "Your sample is labelled the moment it is taken, and only you or your doctor can see your results." },
              { t: "Checked by a doctor", d: "A qualified lab doctor reviews and approves every result before you get it." },
              { t: "Modern, well-kept equipment", d: "Our machines are checked every day so your results are accurate." },
            ].map((r, i) => (
              <li key={r.t} className="grid grid-cols-[3.5rem_1fr] md:grid-cols-[4.5rem_14rem_1fr] gap-x-4 gap-y-1 py-6 border-b border-border">
                <span className="font-mono text-sm text-primary">0{i + 1} //</span>
                <h3 className="font-display font-semibold text-foreground">{r.t}</h3>
                <p className="col-start-2 md:col-start-3 text-sm text-muted-foreground leading-relaxed">{r.d}</p>
              </li>
            ))}
            <li className="grid grid-cols-2 md:grid-cols-4 pt-8 gap-6">
              {[
                { v: "15+", l: "Years of practice" },
                { v: "200+", l: "Tests available" },
                { v: "24h", l: "Typical result time" },
                { v: "98%", l: "Patient satisfaction" },
              ].map((s) => (
                <div key={s.l}>
                  <p className="font-display text-3xl font-bold text-foreground tabular-nums">{s.v}</p>
                  <p className="font-mono text-[11px] uppercase tracking-wider text-muted-foreground mt-1">{s.l}</p>
                </div>
              ))}
            </li>
          </ol>
        </div>
      </section>

      {/* 4. ARCHITECTURAL OMNIBAR */}
      <section className="bg-primary text-primary-foreground">
        <div className="container grid lg:grid-cols-12">
          <div className="lg:col-span-4 py-8 lg:py-12 lg:pr-10 lg:border-r border-primary-foreground/20 font-mono text-xs tracking-wider space-y-3">
            <p className="opacity-80">[ 02 ] FIND A TEST · 200+ AVAILABLE</p>
            <p className="opacity-70">MOST RESULTS READY SAME DAY</p>
            <h2 className="font-display text-2xl md:text-3xl font-bold tracking-tight pt-2 font-sans">What test do you need?</h2>
          </div>
          <div className="lg:col-span-8 py-8 lg:py-12 lg:pl-10 space-y-5">
            <form
              onSubmit={(e) => { e.preventDefault(); window.location.href = "/services"; }}
              className="flex border border-primary-foreground bg-background"
            >
              <label htmlFor="omni" className="sr-only">Search tests</label>
              <input
                id="omni"
                type="search"
                placeholder="Full Blood Count, HIV, Thyroid…"
                className="flex-1 min-w-0 bg-transparent px-4 py-4 text-base text-foreground placeholder:text-muted-foreground outline-none"
              />
              <button type="submit" className="shrink-0 bg-foreground text-background px-5 md:px-8 font-semibold text-sm transition-opacity hover:opacity-90">
                Search
              </button>
            </form>
            <div className="flex flex-wrap gap-x-5 gap-y-2 font-mono text-xs">
              {["Full Blood Count", "Lipid Profile", "Thyroid Panel", "Hepatitis", "Fertility"].map((t) => (
                <Link key={t} to="/services" className="text-primary-foreground/80 hover:text-primary-foreground underline-offset-4 hover:underline">[{t}]</Link>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* 5. DIAGNOSTIC REGISTRY */}
      <section className="py-20 md:py-28 bg-background">
        <div className="container">
          <div className="flex flex-col lg:flex-row lg:items-end lg:justify-between gap-6 mb-10">
            <div className="max-w-2xl space-y-4">
              <p className="font-mono text-xs tracking-[0.2em] text-primary">[ 03 ] POPULAR TESTS</p>
              <h2 className="font-display text-3xl md:text-4xl font-bold leading-tight tracking-tight">Tests people book most often.</h2>
            </div>
            <Link to="/services" className="font-mono text-xs tracking-wider text-foreground hover:text-primary underline underline-offset-4">
              SEE ALL TESTS →
            </Link>
          </div>

          <div className="flex flex-wrap gap-x-6 gap-y-2 border-b border-border mb-0">
            {testCategories.map((cat) => (
              <button
                key={cat}
                type="button"
                onClick={() => setCategory(cat)}
                className={`font-mono text-xs uppercase tracking-wider py-3 -mb-px border-b-2 transition-colors ${
                  category === cat ? "border-primary text-foreground" : "border-transparent text-muted-foreground hover:text-foreground"
                }`}
              >
                {cat === "All tests" ? "All (200+)" : cat}
              </button>
            ))}
          </div>

          <div className="hidden lg:grid grid-cols-[6rem_1.6fr_1fr_1fr_0.7fr_0.6fr_9rem] gap-4 py-3 border-b border-border font-mono text-[11px] tracking-wider text-muted-foreground">
            <span>CODE</span><span>TEST</span><span>SAMPLE</span><span>FASTING</span><span>RESULTS IN</span><span>CHECKS</span><span className="text-right">BOOK</span>
          </div>
          <ul>
            {visibleTests.map((t) => (
              <li key={t.code} className="grid grid-cols-2 lg:grid-cols-[6rem_1.6fr_1fr_1fr_0.7fr_0.6fr_9rem] gap-x-4 gap-y-2 py-5 border-b border-border items-baseline text-sm">
                <span className="font-mono text-xs text-primary">{t.code}</span>
                <span className="col-span-2 lg:col-span-1 -order-1 lg:order-none font-display font-semibold text-foreground text-base">{t.title}</span>
                <span className="text-muted-foreground"><span className="lg:hidden font-mono text-[10px] block">SAMPLE</span>{t.sample}</span>
                <span className="text-muted-foreground"><span className="lg:hidden font-mono text-[10px] block">FASTING</span>{t.fasting ? "Don't eat for 8–12 hours before" : "No need to fast"}</span>
                <span className="text-foreground tabular-nums"><span className="lg:hidden font-mono text-[10px] block text-muted-foreground">RESULTS IN</span>{t.tat}</span>
                <span className="font-mono tabular-nums text-foreground"><span className="lg:hidden text-[10px] block text-muted-foreground">CHECKS</span>{t.parameters}</span>
                <Link to="/book" className="col-span-2 lg:col-span-1 lg:text-right font-semibold text-primary hover:underline underline-offset-4">Book this test →</Link>
              </li>
            ))}
            {visibleTests.length === 0 && (
              <li className="py-8 border-b border-border text-sm text-muted-foreground">No tests shown here yet — see all tests.</li>
            )}
          </ul>
          <div className="mt-6 flex flex-col sm:flex-row sm:justify-between gap-3 font-mono text-xs text-muted-foreground">
            <p>EVERY RESULT IS CHECKED BY A LAB DOCTOR BEFORE YOU GET IT.</p>
            <a href={buildWhatsAppLink("Hello Green Medical, I'd like to enquire about a test not listed.")} target="_blank" rel="noreferrer" className="text-primary hover:underline underline-offset-4">
              CAN'T FIND YOUR TEST? ASK US →
            </a>
          </div>
        </div>
      </section>

      {/* 6. LOGISTICS DISPATCH BOARD */}
      <section className="border-y border-border">
        <div className="grid lg:grid-cols-12">
          <div className="lg:col-span-5 bg-foreground text-background p-8 md:p-14 flex flex-col justify-between gap-10">
            <div className="space-y-6">
              <p className="font-mono text-xs tracking-[0.2em] opacity-70">[ 04 ] HOME SAMPLE COLLECTION</p>
              <h2 className="font-display text-3xl md:text-4xl font-bold leading-tight tracking-tight text-balance">
                We come to your home or office anywhere in Port Harcourt to take your sample.
              </h2>
            </div>
            <div className="flex flex-wrap gap-3">
              <Link to="/book" className="bg-background text-foreground px-6 py-3 font-semibold text-sm hover:opacity-90 transition-opacity">Book a home visit</Link>
              <a href={buildWhatsAppLink("Hello Green Medical, I'd like to schedule a home sample pickup.")} target="_blank" rel="noreferrer" className="border border-background/40 px-6 py-3 font-semibold text-sm hover:bg-background/10 transition-colors">Chat on WhatsApp</a>
            </div>
          </div>
          <ol className="lg:col-span-7 grid md:grid-cols-3 divide-y md:divide-y-0 md:divide-x divide-border bg-background">
            {[
              { t: "Safe, clean sample", d: "A trained nurse takes your sample using new, sealed equipment and labels it on the spot." },
              { t: "Kept cool on the way", d: "Your sample travels in a cooled box so it stays in perfect condition." },
              { t: "Tested right away", d: "As soon as it arrives, our lab checks it in and starts testing." },
            ].map((s, i) => (
              <li key={s.t} className="p-8 md:p-10 flex flex-col gap-4">
                <span className="font-mono text-xs text-primary">STEP 0{i + 1}</span>
                <h3 className="font-display font-semibold uppercase tracking-wide text-sm text-foreground">{s.t}</h3>
                <p className="text-sm text-muted-foreground leading-relaxed">{s.d}</p>
              </li>
            ))}
          </ol>
        </div>
      </section>

      {/* 7. SECURE RESULTS TERMINAL */}
      <section className="bg-primary text-primary-foreground">
        <div className="container">
          <div className="grid lg:grid-cols-12 gap-8 py-14 md:py-20 items-center">
            <div className="lg:col-span-6 space-y-3">
              <p className="font-mono text-xs tracking-[0.2em] opacity-80">[ 05 ] YOUR RESULTS · SAFE & PRIVATE</p>
              <h2 className="font-display text-2xl md:text-3xl font-bold tracking-tight">Get your test results online.</h2>
              <p className="text-sm opacity-80">Type the code printed on your receipt. It looks like <span className="font-mono">GMD-12345</span>.</p>
            </div>
            <form
              onSubmit={(e) => { e.preventDefault(); window.location.href = "/results"; }}
              className="lg:col-span-6 flex flex-col sm:flex-row border border-primary-foreground/40"
            >
              <label htmlFor="ref" className="sr-only">Receipt code</label>
              <input id="ref" placeholder="GMD-00000" className="flex-1 min-w-0 bg-transparent px-4 py-4 font-mono text-primary-foreground placeholder:text-primary-foreground/50 outline-none" />
              <button type="submit" className="bg-primary-foreground text-primary px-6 py-4 font-semibold text-sm hover:opacity-90 transition-opacity">View my results</button>
            </form>
          </div>
        </div>
      </section>

      {/* 8. STATION INDEX & MAP */}
      <section className="py-20 md:py-28 border-t border-border bg-background">
        <div className="container grid lg:grid-cols-12 gap-12">
          <div className="lg:col-span-5 space-y-8">
            <div className="space-y-4">
              <p className="font-mono text-xs tracking-[0.2em] text-primary">[ 06 ] VISIT US</p>
              <h2 className="font-display text-3xl md:text-4xl font-bold tracking-tight">Opening hours.</h2>
            </div>
            <dl className="border-t border-border text-sm">
              {[
                ["Walk-in tests", "Mon – Sat, 07:30 – 18:00"],
                ["Home visits", "Mon – Sat, 07:00 – 16:00"],
                ["Speak with a lab doctor", "Mon – Fri, 09:00 – 17:00"],
                ["Urgent tests", "On-call 24/7"],
              ].map(([k, v]) => (
                <div key={k} className="flex justify-between gap-4 py-4 border-b border-border">
                  <dt className="text-foreground font-medium">{k}</dt>
                  <dd className="font-mono text-xs text-muted-foreground text-right tabular-nums">{v}</dd>
                </div>
              ))}
            </dl>
            <div className="space-y-2 text-sm">
              <p className="font-mono text-[11px] tracking-wider text-muted-foreground">ADDRESS</p>
              <p className="text-foreground leading-relaxed">{SITE.address}</p>
            </div>
            <div className="space-y-2 text-sm">
              <p className="font-mono text-[11px] tracking-wider text-muted-foreground">TELEPHONE</p>
              {SITE.phones.map((p) => (
                <a key={p} href={`tel:${p.replace(/\s/g, "")}`} className="block font-mono text-foreground hover:text-primary">{p}</a>
              ))}
              <a href={buildWhatsAppLink("Hello Green Medical, I have a question.")} target="_blank" rel="noreferrer" className="inline-block pt-2 font-semibold text-primary hover:underline underline-offset-4">Chat on WhatsApp →</a>
            </div>
          </div>
          <div className="lg:col-span-7">
            <div className="relative border border-foreground p-2">
              <span className="absolute -top-5 left-0 font-mono text-[10px] text-muted-foreground">4.8156° N</span>
              <span className="absolute -top-5 right-0 font-mono text-[10px] text-muted-foreground">7.0498° E</span>
              <div className="relative min-h-[420px] h-full">
                <iframe
                  title="Green Medical Diagnostics location"
                  src="https://www.google.com/maps?q=Elioprawo,+Port+Harcourt&output=embed"
                  className="absolute inset-0 w-full h-full grayscale"
                  loading="lazy"
                  referrerPolicy="no-referrer-when-downgrade"
                />
              </div>
              <span className="absolute -bottom-5 left-0 font-mono text-[10px] text-muted-foreground">STN-01 / PORT HARCOURT</span>
            </div>
          </div>
        </div>
      </section>
    </Layout>
  );
};

export default Index;
