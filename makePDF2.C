void processDir(TDirectory *dir, TCanvas *c, const char *pdfname) {
    TIter next(dir->GetListOfKeys());
    TKey *key;

    while ((key = (TKey*)next())) {
        TObject *obj = key->ReadObj();

        if (obj->InheritsFrom("TDirectory")) {
            processDir((TDirectory*)obj, c, pdfname);
        }
        else if (obj->InheritsFrom("TCanvas")) {
            TCanvas *can = (TCanvas*)obj;
            can->Draw();
            can->Print(pdfname);
        }
        else if (obj->InheritsFrom("TH1")) {
            TH1 *h = (TH1*)obj;
            c->cd();
            c->Clear();
            if (h->InheritsFrom("TH2")) h->Draw("colz");
            else h->Draw();
            c->Print(pdfname);
        }
    }
}

void makePDF2() {
    TFile *f = TFile::Open("timeWalkHistos2.root");

    const char *pdfname = "timeWalkHistos2.pdf";
    TCanvas *c = new TCanvas();
    c->Print(Form("%s[", pdfname));

    processDir(f, c, pdfname);   // f is itself a TDirectory (TFile inherits from TDirectory)

    c->Print(Form("%s]", pdfname));
}
