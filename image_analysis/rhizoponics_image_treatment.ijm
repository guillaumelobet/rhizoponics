
/**
* author Guillaume Lobet - Université de Liège (Belgium)
* 
* The aim of this macro is to (1) segment and (2) measure roots grown in the 
* Rhizoponic setup (Mathieu et al., submitted).
* 
*/



// Initial parameters
setBatchMode(true);
run("Set Measurements...", "area centroid center redirect=None decimal=2");

// Define the directories for the analysis
dir = getDirectory("Where are your raw images");
dir1 = getDirectory("Where are you want to save the converted images?");

// Create a dialog with options for the user

Dialog.create("Rhizoponic analysis");
Dialog.addNumber("Centimeters: ", 15);
Dialog.addNumber("Pixels: ", 1300);
Dialog.addCheckbox("Review processing ", false);

// Show the dialog
Dialog.show();

// Ge tthe dialog options
cm = Dialog.getNumber;
px = Dialog.getNumber;
review=Dialog.getCheckbox;


// Get the raw images
list = getFileList(dir);
num = list.length;

// Loop over the file list to analyse all the images
for(k = 0 ;k < num ; k++){

	// Get the file and open it
	t = dir + list[k];
	print(list[k]);
	open(t);
	
	// Get the file name
	ti=getTitle();
	
	// Rotate the image (specific to our setup)
	run("Rotate 90 Degrees Right");
	run("Rotate... ", "angle=1.5 grid=1 interpolation=Bilinear");

	// Ge the blue channel, the one offering the best contrast
	run("RGB Stack");
	run("Delete Slice");
	run("Delete Slice");

	// Crop the image using the custom crop function (see below)
	crop();
	
	// Threshold the image using a local thresholding algorithm
	run("Invert");
	run("Auto Local Threshold...", "method=Sauvola radius=20 parameter_1=0.1 parameter_2=0");

	w=getWidth();
	h=getHeight();

	// Analyse all the particules in the image, 
	// excluding the particules smaller the 20 pixels
	run("Analyze Particles...", "size=20-Infinity circularity=0.00-1.00 show=Masks add display clear");
	selectWindow(ti);
	close();
	selectWindow("Mask of " + ti);

	// Compute the mean particule size and the mean particule Y position
	// This is used to filter the particules, based on the properties of the 
	// roots in the image
	totPart = 0;
	totY = 0;
	if(nResults() > 0){
		for(i = 0; i < nResults(); i++){
				totPart = totPart + getResult("Area", i);
				totY = totY + getResult("YM", i);
		}
	}
	meanPart = totPart / 	nResults();
	meanY = totY / nResults();


	// filter the particules
	w=getWidth();
	h=getHeight();
	if(nResults() > 0){
		for(i = 0; i < nResults(); i++){
			if(   
				getResult("YM", i) < 20 || 				// Too close to the top side
				getResult("YM", i) > (h * 0.8) || 		// Too close to the bottom side
				//getResult("YM", i) > (meanY * 2.5) || 	// Too far from the root system
				getResult("XM", i) < (w / 5) || 		// Too close to the left side
				getResult("XM", i) > (w-(w / 5)) ||		// Too close to the right side
				getResult("Area", i) < meanPart*0.5 
				){
					roiManager("Select", i);
					run("Clear", "slice");
			}
		}
	roiManager("Delete");
	}
	
	makeRectangle(0, 0, w, h);
	run("Invert");

	// Remove overlay left from the ROI manager
	run("Remove Overlay");

	
	// Save the converted image
	saveAs("Tiff", dir1+list[k]);
	close();
}


//---------------------------------------------------------------

if(review){

	setBatchMode(false);
	list = getFileList(dir1);
	num = list.length;
	
	for(k = 0 ;k < num ; k++){
		t = dir1 + list[k];
		print(list[k]);
		open(t);
		
		// Need to invert the image to use the "Clear outside" command
		h = getHeight();	
		w = getWidth();			
		makeRectangle(0, 0, w, h);
		run("Invert");
		
		setTool("rectangle");
		waitForUser("Create a shape around the root system");
		run("Clear Outside");	

		makeRectangle(0, 0, w, h);
		run("Invert");

		saveAs("Tiff", dir1+list[k]);
		close();

	}
	setBatchMode(true);
}


//---------------------------------------------------------------


// Measure all the images
setBatchMode(true);
list = getFileList(dir1);
num = list.length;

run("Clear Results");

// Creation of arrays containing the values for each image
widthA = newArray(num);
areaA = newArray(num);
heightA = newArray(num);
dirA = newArray(num);
diamA = newArray(num);

for(k = 0 ;k < num ; k++){
	
	t = dir1 + list[k];
	print(list[k]);
	open(t);
	ti=getTitle();
	
	// Create a selection to reset any previous ones
	h = getHeight();	
	w = getWidth();			
	makeRectangle(0, 0, w, h);
	
	run("Set Measurements...", "area bounding feret's area_fraction display redirect=None decimal=2");
	run("Set Scale...", "distance="+px+" known="+cm+" pixel=1 unit=cm");
	run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 clear");

	// Initialise the different variables
	area = 0;
	diam = 0;
	ang = 0;
	minX = 10000;
	maxX = 0;
	minY = 10000;
	maxY = 0;
	
	for(i = 0; i < nResults(); i++){	
		f = 90 - getResult("FeretAngle", i);			if(f < 0) f = -f;
		area = area + getResult("Area", i) ;
		diam = diam + getResult("MinFeret", i) ;
		ang = ang + f ;
		bx = getResult("BX", i) + getResult("Width", i); 
		by = getResult("BY", i) + getResult("Height", i); 
		if(bx < minX) minX = bx;
		if(bx > maxX) maxX = bx;
		if(by < minY) minY = by;
		if(by > maxY) maxY = by;
	}
	
	print("maxX = "+maxX+" / minX = "+minX+" / maxY = "+maxY+" / minY = "+minY);

	// Store the variables
	dirA[k] = ang / nResults();
	diamA[k] = diam / nResults();
	areaA[k] = area;
	widthA[k] = maxX-minX;
	heightA[k] = maxY-minY;
	
	close();
}

//---------------------------------------------------------------

// Send the data to a data table
run("Clear Results");
for(k = 0 ;k < num ; k++){
	setResult("Image", k, list[k]);
	setResult("Width", k, widthA[k]);
	setResult("Height", k, heightA[k]);
	setResult("Area", k, areaA[k]); 
	setResult("Direction", k, dirA[k]); 
	setResult("Diameter", k, diamA[k]); 
}


print("Done");

//---------------------------------------------------------------
//---------------------------------------------------------------

// Custom function to crop the image to the rhizotron mesh boundary
// Might need to be adapted for a new setup.

function crop(){

	setBatchMode(true);

	t=getTitle();

  	w=getWidth();
	h=getHeight();
	xS = w/6;
	yS = 0;
	xE = w - (2*(w/6));;
	yE = 0;

	for(j = 0; j < 2; j++){
		t=getTitle();
		run("Duplicate...", "title=[temp]");
		selectWindow("temp");	
		run("Variance...","radius=1");
		run("Maximum...","radius=1");
		for(i=0; i<3; i++) run("Smooth");

	  	w=getWidth();
		h=getHeight();
		xRStart = w/6;
		yRStart = 0;
		searchStart = 0;
		xREnd = w - (2*(w/6));
		yREnd = 0;
		get = false;

		//y start
		for(p= searchStart ; p < h/3; p++){
			if(!get){
				makeRectangle(xRStart, p, xREnd, 1);
				getStatistics(area, mean, min, max, std, histogram);
				if((max > 220 && min > 40) || (max > 220 && mean > 200)){
					yRStart = p;
					get = true;
				}
			}
		}
		yS = yS + yRStart+10; 
		yE = h-500;
		makeRectangle(xS, yS, xE, yE);
		close();
		selectWindow(t);
		makeRectangle(xS, yS, xE, yE);
	}
	run("Crop");
}
