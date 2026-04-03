
void xs_ys(TString histname) {

  // Grab the histo
  TH1F *h1d;
  TH2F *h2d;

  h1d = dynamic_cast <TH1F*> (gDirectory->Get(histname));
  h2d = dynamic_cast <TH2F*> (gDirectory->Get(histname));

  // Grab histo directly if it does not already exist
  if(!h1d && !h2d) {
    // UserScript();
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
    h1d->SetStats(1);
    h1d->Draw();
  }
}  // kpp_analysis function
