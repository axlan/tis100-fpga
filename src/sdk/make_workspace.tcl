setws tis100/workspace
cd tis100/workspace
app create -name tis100_test -hw ../design_top_wrapper.xsa -os standalone -proc ps7_cortexa9_0 -template {Empty Application}
cd ../..
importsources -name tis100_test -path src/sdk