
void UserScript() {

  
  // Declare variables
  Double_t delta,xs,ys,npe,ytar;

  Int_t nentries;

  // Declare Histos
  TH1F *h_delta;
  TH1F *h_xs;
  TH2F *h_xs_ys;

  // Declare trees
  TTree *T = (TTree*) gDirectory->Get("T");

  // Acquire the number of entries
  nentries = T->GetEntries();

  T->SetBranchAddress("H.gtr.dp", &delta);
  T->SetBranchAddress("H.gtr.y", &ytar);
  T->SetBranchAddress("H.extcor.xsieve", &xs);
  T->SetBranchAddress("H.extcor.ysieve", &ys);
  T->SetBranchAddress("H.cer.npeSum", &npe);

  h_delta = new TH1F("h_delta", "Delta(%); Delta (%); Counts / 0.1%", 301, -15, 15);
  h_xs = new TH1F("h_xs", "Xsieve ( cut on ysieve and ytar) ; Xseive (cm); ", 100, -15, 15);
  h_xs_ys = new TH2F("h_xs_ys", "Xsieve vs Ysieve cut on ytar) ; Xsieve (cm); Ysieve (cm)", 100,-10,10,100, -15, 15);


  // Loop of entries in tree
  for(UInt_t ievent = 0; ievent < nentries; ievent++) {

    T->GetEntry(ievent);

    if ((ievent)%1000 == 0) cout << "ievent = " << ievent << endl;
    
    h_delta -> Fill (delta);  
    if (abs(delta)<8&abs(ytar+.4)<.5&&abs(ys+0.2)<0.7&&npe>2) h_xs -> Fill (xs);  
    if (abs(delta)<8&abs(ytar+.4)<.5&&npe>2) h_xs_ys -> Fill (ys,xs);  

  }  // Entries loop
}  // UserScript function

void delta_hms(TString histname) {

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
