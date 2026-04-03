
void UserScript() {

  
  // Declare variables
  Double_t W, th_pq, Q2;

  Int_t nentries;

  // Declare Histos
  TH2F *h_W_vs_th_pq;
  TH2F *h_Q2_vs_th_pq;
  TH2F *h_Q2_vs_W;

  // Declare trees
  TTree *T = (TTree*) gDirectory->Get("T");

  // Acquire the number of entries
  nentries = T->GetEntries();

  T->SetBranchAddress("P.kin.primary.W", &W);
  T->SetBranchAddress("P.kin.primary.Q2", &Q2);
  T->SetBranchAddress("H.kin.secondary.th_xq", &th_pq);


  h_W_vs_th_pq    = new TH2F("h_W_vs_th_pq",    "W vs thpq; thpq (deg);  W (GeV)", 180, 0, 90, 120, 0.6, 1.8);
  h_Q2_vs_th_pq   = new TH2F("h_Q2_vs_th_pq",   "Q2 vs thpq; thpq (deg);  Q2 (GeV2)", 180, 0.0, 90, 100, 0, 0.1);
  h_Q2_vs_W       = new TH2F("h_Q2_vs_W",   "Q2 vs W; W (GeV);  Q2 (GeV2)", 120, 0.6, 1.8, 100, 0, 0.1);

  // Loop of entries in tree
  for(UInt_t ievent = 0; ievent < nentries; ievent++) {

    T->GetEntry(ievent);

    if ((ievent)%10000 == 0) cout << "ievent = " << ievent << endl;
    
    h_W_vs_th_pq -> Fill (th_pq*180.0/3.141592, W);  
    h_Q2_vs_th_pq -> Fill (th_pq*180.0/3.141592, Q2);
    h_Q2_vs_W     -> Fill (W, Q2);
  }  // Entries loop
}  // UserScript function

void ndelta_coin(TString histname) {

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
