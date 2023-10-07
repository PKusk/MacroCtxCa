<!-- 
  <<< Author notes: Header of the course >>> 
  Include a 1280×640 image, course title in sentence case, and a concise description in emphasis.
  In your repository settings: enable template repository, add your 1280×640 social image, auto delete head branches.
  Add your open source license, GitHub uses Creative Commons Attribution 4.0 International.
-->

# MacroCtxCa

_Analysis pipeline for widefield cortical Ca<sup>2+</sup> imaging data from mice._

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

1. Convert image data into seperate tiff stacks and keep track of meta-data. 

   - If you like me have been working with a Leica imaging system that produces .lif files, you can convert all image stacks in the .lif file to tiff stacks using the function `bf_lif2tiff.m`. This also outputs relevant meta-data in a tabular .xlsx format. You will need um per pixel and sampling rate information.
   - I would recommend binning images to 256x256 or 128x128 if you have >10000 frames. This can be done automatically with the `bf_lif2tiff.m` function in the last input. 
   - If you have many .lif files that needs conversion, the `lif_batch_processing.m` can be used.

2. Generate and apply automatic cortex outline mask to image stack.
    - Open `PK_MacroCtxCa_Pipeline.m`, input relevant data path and file names for image stacks, meta data and stimulation file (optional) and run the section.
    - Run the automatic mask section and evaluate the result. Don't worry if it is not perfect.
      
4. Align images and mask to location of bregma and lambda.
    - Run the section. A pop-up window will let you indicate first location of bregma and then location lambda manually. 
    - Review the result and re-run the section if needed. You want the skull to be positioned in the middle of the image with the midline as parallel to the y-axis as possible.
      
5. Generate cortex anatomical annotations map from the Allen brain atlas Common Coordinate Framework (ACCF) and the aligned mask.
    - Run the section. If you wish to review the map location and cropping input the `accf_regions` output in `imagesc`. 
   
6. Extract the top 40 independent components from the image stack using the PCA and JADE, approach from [Makino et al. 2017, Neuron](https://doi.org/10.1016/j.neuron.2017.04.015).
   -
   
9. Annotate spatial components to the ACCF map.

## Temporal component scoring

## ICA clustering using k-means


---

Get help: [Post in our discussion board](https://github.com/skills/.github/discussions) &bull; [Review the GitHub status page](https://www.githubstatus.com/)

&copy; 2022 GitHub &bull; [Code of Conduct](https://www.contributor-covenant.org/version/2/1/code_of_conduct/code_of_conduct.md) &bull; [MIT License](https://gh.io/mit)
