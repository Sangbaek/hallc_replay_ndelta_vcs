TFile *f = TFile::Open("windows.root");

// Open the PDF
TCanvas *c = new TCanvas();
c->Print("output.pdf[");

// Loop over all objects in the file
TIter next(f->GetListOfKeys());
TKey *key;

while ((key = (TKey*)next())) {
    TObject *obj = key->ReadObj();

    if (obj->InheritsFrom("TCanvas")) {
        TCanvas *can = (TCanvas*)obj;
        can->Draw();
        can->Print("output.pdf");   // add page
    }
}

// Close the PDF
c->Print("output.pdf]");
