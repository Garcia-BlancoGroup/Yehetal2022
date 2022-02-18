setOption("ScaleConversions", true);
run("8-bit");
run("Subtract Background...", "rolling=50");
//setAutoThreshold("Default dark");
setThreshold(25, 255);
setOption("BlackBackground", false);
run("Convert to Mask");
