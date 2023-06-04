function   bf_lif2tiff(Lif_Path,Tiff_Path,SeriesIdx,bin)
% bf_lif2tiff(Lif_Path,Tiff_Path,SeriesIdx,bin)
% Written by P.Kusk 2021.02.19
% You need the matlab bioformats package to run this function: https://www.openmicroscopy.org/bio-formats/downloads/
% The purpose of this function is to convert Leica Microscope .lif files to
% .tiff stacks and a corresponding meta-data table that will allow further
% batch processing. Function is optimized for single channel, single Z, time
% series but can easily be altered to fit other needs. Function allows tiff
% to be saved other directory and for specific series to be extracted from
% tiff and also a build-in binning. if only .lif path is inputted no
% binning and all series will save in same folder location.
% 2021.02.22 - P.Kusk - Updated the function to use time-stamps to output actual framerate and date, time of acquisition.
% 2021.03.16  -P.Kusk - Updated the function to output only meta-data if you put in 'MetaOnly' in the Tiff_Path Slot. also did a string search for the OME-metadata instead of hard-coding the indexing in cases where stuff  meta data has changed position for any reason.
% Extracting Lif info before loading image.
% 2021.04.15 - P.Kusk added a continue statement in case the function won't run for a series

Reader = bfGetReader(Lif_Path);
LifDirInfo = dir(Lif_Path);
if isempty(Tiff_Path) || nargin < 2
    TiffDirInfo = dir(Lif_Path);
else
    TiffDirInfo = dir(Tiff_Path);
end
if strcmp(Tiff_Path,'MetaOnly')
    TiffDirInfo = dir(Lif_Path);
end

SeriesSize = Reader.getSeriesCount;
omeMeta = Reader.getMetadataStore();
OMEXML = char(omeMeta.dumpXML());

% if no bin or Series index is added then nothing will be binned and all
% series will be processed.
if nargin < 4
    bin = 1;
elseif nargin < 3
    SeriesIdx = 1:SeriesSize;
end

if isempty(SeriesIdx)
    SeriesIdx = 1:SeriesSize;
end

for iSeries = SeriesIdx
    Reader.setSeries(iSeries -1);
    
    % Extracting Basic metadata
    ImageSizeBitperPixel = Reader.getBitsPerPixel;
    ImageSizeY = Reader.getSizeY;
    ImageSizeX = Reader.getSizeX;
    ImageSizeZ = Reader.getSizeZ;
    ImageSizeT = Reader.getSizeT;
    ImageSizeC = Reader.getSizeC;
    SeriesName = {char(omeMeta.getImageName(iSeries-1))};
    fprintf(['Processing ' SeriesName{1} '...' '\n']);
    
    % Calculating the physical pixel size and image dimensions
    umPixelSizeX = double(omeMeta.getPixelsPhysicalSizeX(iSeries-1).value);
    umPixelSizeY = double(omeMeta.getPixelsPhysicalSizeY(iSeries-1).value);
    PhysicalSizeX_um = umPixelSizeX*ImageSizeX;
    PhysicalSizeY_um = umPixelSizeY*ImageSizeY;
    
    % Image dimensions after bin
    BinImageSizeX = ImageSizeX/bin;
    BinImageSizeY = ImageSizeY/bin;
    
    % Converting Series MetaData Hashtable to extract additional metadata.
    h = Reader.getSeriesMetadata;
    % retrieve all key names
    allKeys = arrayfun(@char, h.keySet.toArray, 'UniformOutput', false);
    
    % retrieve all key values
    allValues = cellfun(@(x) h.get(x), allKeys, 'UniformOutput', false);
    
    % Re-constructing the extracted information in a readable "table" format
    %Combined_MetaData_Cell = {allKeys{:}; allValues{:}}';
    
    % It is possible to output many microscope details from the hastable. I
    % will list them here for potential future use but will only include essentials.
    % relevant metadata Idx is row no. of Combined_MetaData_Cell
    % Nice to know: MicroscopeModel: 40, CameraName: 206, ObjectiveName: 18, NumericalApeture: 223, LUT: 176, ScanMode: 67
    % Need to know: FilterCubeName: 50, ZPosition: 27, Zoom: 154, Binning: 156, CompleteTime(seconds): 213, Exposuretime: 237, CycleTime: 174
    % Already known: SeriesName: 233, ImageXDimPixel: 132, ImageYDimPixel: 175, FrameCount: 69, BitDepth: 54
    FilterNameIndex = find(contains(allKeys,'FluoCubeName')==1); FilterName = {char(allValues{FilterNameIndex})};
    ObjectiveNameIndex = find(contains(allKeys,'ObjectiveName')==1); ObjectiveName = {char(allValues{ObjectiveNameIndex})};
    ZoomIndex =find(contains(allKeys,'|SameZoom')==1);  Zoom = str2double(allValues{ZoomIndex});
    ZPositionIndex =find(contains(allKeys,'Image|ATLCameraSettingDefinition|ZPosition')==1); ZPosition = str2double(allValues{ZPositionIndex});
    CompleteTimeIndex =find(contains(allKeys,'|CompleteTime')==1); CompleteTime = str2double(allValues{CompleteTimeIndex});
    ExposureTimeIndex =find(contains(allKeys,'|ExposureTime')==1); ExposureTime = str2double(allValues{ExposureTimeIndex});
    CycleTimeIndex =find(contains(allKeys,'|CycleTime')==1); CycleTime = str2double(allValues{CycleTimeIndex});
    
    Lif_File_Name = {LifDirInfo.name};
    Tiff_File_Name = {[TiffDirInfo(1).folder '\' LifDirInfo.name(1:end-4) '_' SeriesName{1} '.tif']};
    Meta_Table_Name = {[TiffDirInfo(1).folder '\' LifDirInfo.name(1:end-4) '_' SeriesName{1} '_MetaData.xlsx']};
    
    % ATTENTION! Though the MetaData of total duration of stack and the "CycleTime" which is the inter-frame duration is outputted, these
    % numbers are incorrect for some reason for the Nedergaard Leica macroscope. Example: recording with a cycletime of 0.0474s should
    % correspond to a sampling rate of around 21.1 Hz. However after recording the camera's frame trigger output with the digitizer
    % we observed an inter-frame interval of very close to 0.0500s which corresponds to 20Hz. This inaccuracy will accumulate from a 354s
    % recoding to become 372s long.. almost 20s difference over 6min. It's fucked mate but just FYI.
    
    %2021.02.22  - Managed to locate the aqcusition date and frame time
    %stamps. Will output date and calcute the real sampling rate from the
    %timestamps.
    Series_OMEXML = extractBetween(OMEXML,SeriesName{:},'/Pixels');
    SeriesAcquisitionDateTime = split(extractBetween(Series_OMEXML(1),'AcquisitionDate>','</AcquisitionDate'),'T');
    % Relevant Values
    SeriesAcquisitionDate = SeriesAcquisitionDateTime(1);
    SeriesAcquisitionTime = SeriesAcquisitionDateTime(2);
    SeriesTimeStampsCell = extractBetween(Series_OMEXML(1),'Plane DeltaT="','" DeltaTUnit');
    %SeriesFrameCounts = extractBetween(Series_OMEXML,'TheT="','" TheZ="0"/');
    
    % Converting strings within cells to double array.
    SeriesTimeStamps = [];
    for ii = 1:length(SeriesTimeStampsCell)
        SeriesTimeStamps(ii,:) = str2double(SeriesTimeStampsCell{ii});
    end
    
    % Using the mean time gap between timestamps to estimate the real frame
    % rate. Note: this matches the .abf determined FrameRate
    SeriesRealFrameRate = 1/mean(diff(SeriesTimeStamps));
    SeriesRealCompletionTime = SeriesTimeStamps(end);
    
    %Writing relevant metadata into a table format.
    Meta_Table = table(Lif_File_Name,SeriesName,SeriesAcquisitionDate,SeriesAcquisitionTime,...
        BinImageSizeX, BinImageSizeY, PhysicalSizeX_um, PhysicalSizeY_um, ImageSizeT, ImageSizeBitperPixel,SeriesRealFrameRate,SeriesRealCompletionTime, ...
        ExposureTime, CycleTime, CompleteTime, FilterName, ObjectiveName, ZPosition, Zoom, Tiff_File_Name,Meta_Table_Name);
    
    if strcmp(Tiff_Path,'MetaOnly')
        writetable(Meta_Table, Meta_Table_Name{1})
    else
        iZ = 1:ImageSizeZ; %  if series has multiple Z levels
        iC = 1:ImageSizeC; %  if series has multiple color channels
        I = zeros(BinImageSizeY,BinImageSizeX,ImageSizeT,'uint16'); % Pre-allocating memory for image stack, extent this if multiple colors or Z-planes.
        try
            for iT = 1:ImageSizeT % If Series has multiple time points
                iPlane = Reader.getIndex(iZ -1, iC -1, iT -1) +1;
                I(:,:,iT) = imresize(bfGetPlane(Reader, iPlane),1/bin);
            end
            
            saveastiff(I,Tiff_File_Name{1}); %Tested Elapsed time is 348.860825 seconds. for 256x256x7440 uint16
            
            %imwrite tested Elapsed time is 157.545085 seconds. for 256x256x7440 uint16
            %     imwrite(I(:,:,1),Tiff_File_Name{1})
            %     for ii = 2:ImageSizeT
            %         imwrite(I(:,:,ii),Tiff_File_Name{1},'WriteMode','append')
            %     end
            writetable(Meta_Table, Meta_Table_Name{1})
        catch
            continue
        end
    end
end
end