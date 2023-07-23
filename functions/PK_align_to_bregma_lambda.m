function[aligned_image_stack, bregma, lambda] = PK_align_to_bregma_lambda(image_data,bregma,lambda)
% [aligned_image_stack, bregma, lambda] = PK_align_to_bregma_lambda(image_data,bregma,lambda)
% 2023.05.15 - P.Kusk - Function to align macroscope images based on the location of the bregma and lambda.
% Function takes in an image stack (uint16 tiff stack) and [X Y] coordinates for bregma and lambda locations. 
% If bregma/lambda is left empty [], the user will be asked to input these by clicked to spots on the first frame.
% Image stack is rotated to align bregma and lambda and center the location of bregma.

% Code is based on the ACCF tools by the UCL Cortex lab (Awesome stuff, https://github.com/cortex-lab)

% Get user input on bregma/lambda location
if isempty(bregma)
    figure,
    ref_image = uint16(image_data(:,:,1));
    imshow(imadjust(ref_image));
    fprintf(1, 'click bregma\n');
    [x,y] = ginput(1);
    bregma = [y,x]
    fprintf(1, 'click lambda\n');
    [x,y] = ginput(1);
    lambda = [y,x]
    close gcf
end

tic;
fprintf('Aligning images based on bregma/lambda input ...')

% Center bregma location on image 50% width and 50% height
[height,width,~]=size(image_data);
image_center = [height*0.5 width*0.5];
center_diff = image_center - bregma;
TI = imtranslate(image_data, fliplr(center_diff)); % translated image stack.
%figure,imshowpair(ref_image,TI,'montage')

% Rotate image based on the angle between bregma and lambda
apDir = lambda-bregma; apDir = apDir./norm(apDir);
theta = -atan(apDir(2)/apDir(1))*180/pi;
RI = imrotate(TI,theta,'crop'); % rotated image stack
%figure, imshowpair(TI,RI,'montage')

aligned_image_stack = RI;

fprintf(['done (', num2str(toc),' s).\n']);

end