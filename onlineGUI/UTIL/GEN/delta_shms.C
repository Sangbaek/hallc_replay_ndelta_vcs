
void UserScript() {

  
  // Declare variables
  Double_t delta, W, Q2, nu, e_px, e_py, e_pz, e_e;
  Double_t px_virt, py_virt, pz_virt;
  Double_t e_beam = 1.4189;
  Double_t m_e    = 0.511e-3;
  Double_t m_p    = 0.938272;
  Double_t p_beam = TMath::Sqrt(e_beam * e_beam - m_e * m_e);

  Int_t nentries;

  // Declare Histos
  TH1F *h_delta;
  TH1F *h_W;
  TH1F *h_Q2;
  TH1F *h_nu;

  // Declare trees
  TTree *T = (TTree*) gDirectory->Get("T");

  // Acquire the number of entries
  nentries = T->GetEntries();

  T->SetBranchAddress("P.gtr.dp", &delta);
  T->SetBranchAddress("P.gtr.px", &e_px);
  T->SetBranchAddress("P.gtr.py", &e_py);
  T->SetBranchAddress("P.gtr.pz", &e_pz);
  T->SetBranchAddress("P.kin.W", &W);
  T->SetBranchAddress("P.kin.Q2", &Q2);
  T->SetBranchAddress("P.kin.nu", &nu);


  h_delta = new TH1F("h_delta", "Delta(%); Delta (%); Counts / 0.1%", 501, -25, 25);
  h_W     = new TH1F("h_W",    "W (GeV); W (GeV);  Counts / 0.001 GeV", 101, 0.5, 1.5);
  h_nu    = new TH1F("h_nu",   "nu (GeV); nu (GeV);  Counts / 0.005 GeV", 101, 0.0, 0.5);
  h_Q2    = new TH1F("h_Q2",   "Q2 (GeV2); Q2 (GeV2);  Counts / 0.005 GeV2", 101, 0.0, 0.5);

  // Loop of entries in tree
  for(UInt_t ievent = 0; ievent < nentries; ievent++) {

    T->GetEntry(ievent);

    if ((ievent)%10000 == 0) cout << "ievent = " << ievent << endl;
    
    h_delta -> Fill (delta);  
    h_W    -> Fill (W);
    h_Q2    -> Fill (Q2);
    h_nu    -> Fill (nu);

  }  // Entries loop
}  // UserScript function

void delta_shms(TString histname) {

  // Grab the histo
  TH1F *h1d;
  TH2F *h2d;

  h1d = dynamic_cast <TH1F*> (gDirectory->Get(histname));
  h2d = dynamic_cast <TH2F*> (gDirectory->Get(histname));

  // Grab histo directly if it does not already exist
  if(!h1d && !h2d) {
    UserScript();
    h1d = (TH1F*) (gDirectory->Get(histname));
    h2d = (TH2F*) (gDirectory->Get(histname));
    // Throw error
    if(!h1d || !h2d) {
      cout << "User histogram " << histname << " not found" << endl;
      exit(1);
    }
  }
  //else
  if (h2d) {
    h2d->SetStats(0);
    h2d->Draw("colz");
  }
  else {
    h1d->SetStats(0);
    h1d->Draw();
  }
}  // kpp_analysis function
