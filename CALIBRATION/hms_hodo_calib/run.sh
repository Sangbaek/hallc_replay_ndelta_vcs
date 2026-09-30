# Each app supports interactive/ noninteractive mode, but only noninteractive mode was used for TW and lambda part
# root -l -b -q 'timewalk_calib_app.C(26138, 0, "vanilla", true, "0", "", 10.0)'
# root -l -b -q 'timewalk_calib_app.C(26927, 0, "vanilla", true, "1", "", 10.0)'
# compareOnly is now true, so it will not update the TW fit. compareOnly=kFALSE can be used as an argument, or one can update timewalk_calib_app.C

# vp calibration  used interactive mode.
#root -l 'vpcalib_app.C(26138, 0, "vanilla", false, "0", "", 10.0)'
#root -l 'vpcalib_app.C(26927, 0, "vanilla", false, "1", "", 10.0, "", "./vpcalib_qa", "../../PARAM", false, 0.0, false, false)'

# After fitting, produce the pdf using the following command. compareOnly is on.
root -l -b -q 'vpcalib_app.C(26138, 0, "vanilla", true, "0", "", 10.0, "", "./vpcalib_qa", "../../PARAM", true, 0.0, false, true, true, true)'
root -l -b -q 'vpcalib_app.C(26927, 0, "vanilla", true, "1", "", 10.0, "", "./vpcalib_qa", "../../PARAM", false, 0.0, false, false, true, true)'

# lambda calibration
root -l -b -q 'lambda_calib_app.C(26138, "", "0", true, "0", 10.0, 100.0, "", "./lambda_qa", "../../PARAM", "vanilla", true, true, true, false)'
root -l -b -q 'lambda_calib_app.C(26927, "", "1", true, "1", 10.0, 100.0, "", "./lambda_qa", "../../PARAM", "vanilla", false, false, true, false)'

# for comparison only, use the compareOnly flag
#root -l -b -q 'lambda_calib_app.C(26138, "", "0", true, "0", 10.0, 100.0, "", "./lambda_qa", "../../PARAM", "vanilla", true, true, true, true)'
#root -l -b -q 'lambda_calib_app.C(26927, "", "1", true, "1", 10.0, 100.0, "", "./lambda_qa", "../../PARAM", "vanilla", false, false, true, true)'


