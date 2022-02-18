//===============================================================================
// Measure vesicles IntDen loading roi
//===============================================================================
macro "Segment Vesicles"  {
 dirPath = getDirectory( "Choose a Directory" ); 
 segment_vesicles(dirPath);
}

function segment_vesicles(FolderTemplatePath) {
  run("Clear Results");
  list_round1 = getFileList(FolderTemplatePath);
  num_line=0;
  num_image=0;
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
		print(FolderTemplatePath+File.separator+"RoiSet_"+filename+"_best.zip");
		title = getTitle();
	    if(File.exists(FolderTemplatePath+File.separator+"RoiSet_"+filename+"_best.zip.roi")) {
	    	roiManager("Open", FolderTemplatePath+File.separator+"RoiSet_"+filename+"_best.zip.roi");
	    } else {
	    	roiManager("Open", FolderTemplatePath+File.separator+"RoiSet_"+filename+"_best.zip");
	    }
	    selectImage(orig_id);
	    run("Z Project...", "projection=[Max Intensity]");
	    for (u=0; u<roiManager("count"); ++u) {
		    roiManager("Select", u);
		    setSlice(1);
		    roiManager("Measure");
		    setResult("filename", num_line, filename);
		    setResult("channel", num_line, 1);
		    setResult("roi", num_line, u+1);
		    num_line += 1;
		    setSlice(2);
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
  saveAs("Results", FolderTemplatePath + 'info_best.csv');
    
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