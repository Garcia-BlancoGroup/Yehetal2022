//===============================================================================
// Segment cells and measure IntDen
//===============================================================================
macro "Segment Cells"  {
 dirPath = getDirectory( "Choose a Directory" ); 
 segment_cells(dirPath);
}

function segment_cells(FolderTemplatePath) {
  run("Clear Results");
  list_round1 = getFileList(FolderTemplatePath);
  num_line=0;
  for (i = 0; i < list_round1.length; i++) {
	numImage=nImages();  
	namest=toLowerCase(list_round1[i]);
	if (endsWith(namest,".tif")) {
		run("Bio-Formats", "open='"+FolderTemplatePath+File.separator+list_round1[i]+"'"+
		"autoscale color_mode=Grayscale view=Hyperstack");
		run("Set Measurements...", "area mean centroid perimeter integrated median display redirect=None decimal=3");
		filename = getFilename();
		orig_id=getImageID();
		print(FolderTemplatePath+File.separator+list_round1[i]);
		title = getTitle();
	    run("Z Project...", "projection=[Max Intensity]");
	     
	    run("Select None");
	    if(roiManager("count")>0) {
	    	roiManager("Delete");
	    }
	    setOption("BlackBackground", true);
	    rename("proc_image");
		run("Split Channels");
		close("C4-proc_image");
		
		selectImage("C1-proc_image");
		run("Enhance Contrast...", "saturated=0 equalize");
		selectImage("C2-proc_image");
		run("Duplicate...", "duplicate title=3p_UTR");
		selectImage("C2-proc_image");
		run("Enhance Contrast...", "saturated=0 normalize");
		selectImage("C3-proc_image");
		run("Duplicate...", "duplicate title=gRNA");
		selectImage("C3-proc_image");
		run("Enhance Contrast...", "saturated=0 normalize");
		imageCalculator("Add create", "C1-proc_image","C2-proc_image");
		close("C1-proc_image");
		close("C2-proc_image");
		imageCalculator("Add create", "Result of C1-proc_image","C3-proc_image");
		close("Result of C1-proc_image");
		close("C3-proc_image");
		selectWindow("Result of Result of C1-proc_image");
		rename("proc_image");
		run("Maximum...", "radius=5");
		run("Gaussian Blur...", "sigma=5");
		setOption("BlackBackground", true);
		run("Convert to Mask");
		run("Watershed");
		run("Analyze Particles...", "size=20.00-Infinity add");
		close("proc_image");
	    nbr_chrs = roiManager("count") - 1;
	    roiManager("Save", FolderTemplatePath+File.separator+"RoiSet_"+filename+".zip");
	    for (u=0; u<roiManager("count"); u++) {
	    	selectImage("3p_UTR");
		    roiManager("Select", u);
		    roiManager("Measure");
		    setResult("filename", num_line, filename);
		    setResult("channel", num_line, 1);
		    setResult("roi", num_line, u+1);
		    num_line += 1;
		    
		    selectImage("gRNA");
		    roiManager("Select", u);
		    roiManager("Measure");
		    setResult("filename", num_line, filename);
		    setResult("channel", num_line, 2);
		    setResult("roi", num_line, u+1);
		    num_line += 1;
		}
	    
	    run("Select None");
	    if(roiManager("count")>0) {
	    	roiManager("Delete");
	    }
	     while (nImages>numImage) { 
	      selectImage(nImages); 
	      close(); 
	     }
	}
  }
  updateResults();
  saveAs("Results", FolderTemplatePath + 'info.csv');
    
  print('Done!'); 
}


macro "=========================="{} 

function getFilename() {
  t = getTitle();
  ext = newArray(".tif", ".tiff", ".lif", ".lsm", ".czi", ".nd2", ".ND2");    
  for(i=0; i<ext.length; i++)
    t = replace(t, ext[i], "");  
  return t;
}