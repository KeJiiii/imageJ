// input parameters
Dialog.create("get particle ");
	Dialog.addMessage("Enter your setting here");
	Dialog.addNumber("color ratio low", 0);
	Dialog.addNumber("color ratio high", 2);
	Dialog.addNumber("color ratio brightness", 500);
	Dialog.addNumber("color threshold Hue", 180);
	Dialog.addNumber("color threshold brightness", 60);
	Dialog.addNumber("particle size", 80);
	Dialog.addNumber("particle shape mini", 0.3);
	Dialog.addNumber("particle shape max", 1);
	Dialog.addNumber("GBsigma", 1);
Dialog.show();
color_ratio_low=Dialog.getNumber;
color_ratio_high=Dialog.getNumber;
color_ratio_brightness=Dialog.getNumber;
Hue=Dialog.getNumber;
braightness=Dialog.getNumber;
scale=Dialog.getNumber;
circle1=Dialog.getNumber;
circle2=Dialog.getNumber;
GBsigma=Dialog.getNumber;


// get directory
select_path = getDirectory("Choose the Input Directory");


// get color threshold mask, 
function get_color_threshold_mask(inputstacks,Hue,braightness) {
	selectWindow(inputstacks);
	getDimensions(width, height, channels, slices, frames);
	print(slices);
	for (n = 0; n < slices; n++) {
		selectWindow(inputstacks);
		run("Duplicate...", "duplicate range="+n+1+"-"+n+1+" use");
		a=getTitle();
		min=newArray(3);
		max=newArray(3);
		filter=newArray(3);
		selectWindow(a);
		run("HSB Stack");
		run("Convert Stack to Images");
		selectWindow("Hue");
		rename("0");
		selectWindow("Saturation");
		rename("1");
		selectWindow("Brightness");
		rename("2");
		min[0]=0;
		max[0]=Hue;
		filter[0]="pass";
		min[1]=0;
		max[1]=255;
		filter[1]="pass";
		min[2]=braightness;
		max[2]=255;
		filter[2]="pass";
		for (i=0;i<3;i++){
		  selectWindow(""+i);
		  setThreshold(min[i], max[i]);
		  run("Convert to Mask");
		  if (filter[i]=="stop")  run("Invert");
		}
		imageCalculator("AND create", "0","1");
		imageCalculator("AND create", "Result of 0","2");
		for (i=0;i<3;i++){
		  selectWindow(""+i);
		  close();
		}
		selectWindow("Result of 0");
		close();
		selectWindow("Result of Result of 0");
		rename("flow_"+n+1);
	}
	run("Images to Stack", "name=Stack title=flow_");
}



son_file_list=getFileList(select_path);
for (l = 0; l < son_file_list.length; l++){
	if (startsWith(son_file_list[l],"rem_")){
		// from BLk data to color threshold mask,raw mean the window,not the directory
		print("son_file============================="+son_file_list[l]);
		open(select_path+son_file_list[l]);
		raw=getTitle();
		print(raw);
		selectWindow(raw);
		run("Duplicate...", "duplicate channels=1");
		img1=getTitle();
		selectWindow(raw);
		run("Duplicate...", "duplicate channels=2");
		img2=getTitle();
		run("Color Ratio Plus v1", "image1=["+img1+"] image2=["+img2+"] background1=0 clipping_value1=0 background2=0 clipping_value2=0 multiplication=1 color_scale_low="+color_ratio_low+" color_scale_high="+color_ratio_high+" brightness="+color_ratio_brightness);
		// next operation may translocation 
		run("Gaussian Blur...", "sigma="+GBsigma+" stack");
		img3=getTitle();
		//selectWindow(img1);
		//close();
		//selectWindow(img2);
		//close();
		get_color_threshold_mask(img3,Hue,braightness);
		selectWindow("Stack");
		
		// generate ROI; input parameter: scale; circle1; circle2 
		selectWindow("Stack");
		/*
		run("Convert to Mask", "method=Default background=Dark black");
		
		run("Watershed", "stack");
		run("Analyze Particles...", "size="+scale+"-Infinity circularity="+circle1+"-"+circle2+" display clear include add in_situ stack");
		
		run("Clear Results");
		run("Set Measurements...", "area mean redirect=None decimal=3");
		selectWindow(img1);
		run("Hyperstack to Stack");
		roiManager("Show All");
		roiManager("Multi Measure");
		filename=substring(raw,0,lengthOf(raw)-4);
		nROIs = roiManager("count");
		print(nROIs);
		saveAs("Results", select_path+"list_ch1_"+filename+".csv");
		run("Clear Results");
		selectWindow(img2);
		run("Hyperstack to Stack");
		roiManager("Show All");
		roiManager("Multi Measure");
		saveAs("Results", select_path+"list_ch2_"+filename+".csv");
		roiManager("Show All");
		roiManager("Save", select_path+"ROI_"+nROIs+"_"+filename+".zip");
		run("Clear Results");
		roiManager("Show All");
		roiManager("reset");
		close("*");
		*/
	}
}






