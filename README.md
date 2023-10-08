<!-- 
  <<< Author notes: Header of the course >>> 
  Include a 1280×640 image, course title in sentence case, and a concise description in emphasis.
  In your repository settings: enable template repository, add your 1280×640 social image, auto delete head branches.
  Add your open source license, GitHub uses Creative Commons Attribution 4.0 International.
-->

# MacroCtxCa

_Analysis pipeline for widefield cortical Ca<sup>2+</sup> imaging data of transgenic GCaMP mice._

<!-- 
  <<< Author notes: Start of the course >>> 
  Include start button, a note about Actions minutes,
  and tell the learner why they should take the course.
  Each step should be wrapped in <details>/<summary>, with an `id` set.
  The start <details> should have `open` as well.
  Do not use quotes on the <details> tag attributes.
-->

## Requirements
 - To run the pre-processing code to convert .lif to .tiff you will need the [Bio-Formats MATLAB package](https://www.openmicroscopy.org/bio-formats/downloads/)

## Image data pre-processing

Convert image data into seperate tiff stacks and keep track of meta-data. 

   - If you like me have been working with a Leica imaging system that produces .lif files, you can convert all image stacks in the .lif file to tiff stacks using the function `bf_lif2tiff.m`. This also outputs relevant meta-data in a tabular .xlsx format. You will need um per pixel and sampling rate information.
   - I would recommend binning images to 256x256 or 128x128 if you have >10000 frames. This can be done automatically with the `bf_lif2tiff.m` function in the last input. 
   - If you have many .lif files that needs conversion, the `lif_batch_processing.m` can be used.
     <!-- <img src="https://github.com/PKusk/MacroCtxCa/assets/69124936/7c9c0f7b-2108-471d-b3d0-0c42a27bae41" width="300" height="300"> --!>

## ICA/PCA Based Cortical Activity Segmentation

1. Generate and apply automatic cortex outline mask to image stack.
    - Open `PK_MacroCtxCa_Pipeline.m`, input relevant data path and file names for processed image stacks, meta data and stimulation file (optional) and run the section.
    - Run the automatic mask section and evaluate the result. Don't worry if it is not perfect.  

2. Align images and mask to  bregma and lambda.
    - Run the section. A pop-up window will let you indicate first location of bregma and then location lambda manually. 
    - Review the result and re-run the section if needed. You want the skull to be positioned in the middle of the image with the midline as parallel to the y-axis as possible.

3. Generate cortex anatomical annotations map from the Allen brain atlas Common Coordinate Framework (ACCF) and the aligned mask.
    - Run the section. If you wish to review the map location and cropping input the `accf_regions` output in `imagesc`.

4. Extract the top 40 independent components from the image stack using the PCA and JADE, approach from [Makino et al. 2017, Neuron](https://doi.org/10.1016/j.neuron.2017.04.015).
   - Run the section. The PCA/ICA is pretty demanding and takes time. 
   
5. Annotate spatial components to the ACCF map.
   -  Run the next section. This section annotates each component based on the highest mean value for a given region.
     
6. Score each temporal component based on a generated "score-trace".
   - test
  
7. Evaluate all components with scores and annoations
   
9. Save 

## Spatial IC Homology Analysis using t-SNE and k-means Clustering
_Still in development but the concept here is collect the ICs from the above analysis from multiple recordings and/or conditions and cluster cortical networks with homologous profiles, to evaluate preserved networks under certain behaior/conditions._
