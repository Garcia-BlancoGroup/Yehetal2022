//===============================================================================
// Segment vesicles knowing the best in-focus z-slice
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
  filePath=FolderTemplatePath+File.separator+"focusz.csv";
  Table.open(filePath);
  returnStr=Table.getColumn('slice');
  run("Close");
  for (i = 0; i < list_round1.length; i++) {
	numImage=nImages();
	namest=toLowerCase(list_round1[i]);
	if (endsWith(namest,".tif")) {
		run("Bio-Formats", "open='"+FolderTemplatePath+File.separator+list_round1[i]+"'"+
		"autoscale color_mode=Grayscale view=Hyperstack");
		run("Set Measurements...", "area mean centroid perimeter integrated median display redirect=None decimal=3");
		filename = getFilename();
		orig_id=getImageID();
		print(FolderTemplatePath+File.separator+list_round1[i]+' slice'+returnStr[num_image]);
		title = getTitle();
	    
	    run("Make Substack...", "channels=1-3 slices="+returnStr[num_image]);
	    num_image += 1;

	    setSlice(1);
		run("Enhance Contrast...", "saturated=0.3");
		setSlice(2);
		run("Enhance Contrast...", "saturated=0.3");
		setSlice(3);
		run("Enhance Contrast...", "saturated=0.3");
	    run("Select None");
	    setOption("BlackBackground", true);
	    run("Median...", "radius=2 slice");
	    run("Convert to Mask", "method=Triangle background=Dark calculate black");
	    rename("proc_image");
		run("Split Channels");
		close("C1-proc_image");
		close("C2-proc_image");
		selectWindow("C3-proc_image");
		run("Invert");
		
		rename("proc_image");
	    run("Analyze Particles...", "size=0.1-5 add");
	    close("proc_image");
	    if(roiManager("count")>0) {
	    	roiManager("Save", FolderTemplatePath+File.separator+"RoiSet_"+filename+"_best.zip");
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