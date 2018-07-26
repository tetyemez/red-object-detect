clc;
clear all;
a = imaqhwinfo;
[camera_name, camera_id, format] = getCameraInfo(a);


% Capture the video frames using the videoinput function
% You have to replace the resolution & your installed adaptor name.
vid = videoinput(camera_name, camera_id, format);

% Set the properties of the video object
set(vid, 'FramesPerTrigger', Inf);
set(vid, 'ReturnedColorspace', 'rgb') % hangi görüntü uzayýnda çalýþacaðýmýzý belirliyoruz. video buna göre ayarlýyoruz. biz renk tabanlý nesne takibi yapacaðýmýz için rgb renk uzayýna ayrlýyoruz.
%rgb uzayýnda belirlediðimizde: kýrmýzý yeþil ve mavi renge göre iþlem
%yapabiliyoruz.örneðin:  YCbCr  Y ile luminance (parlaklýk) sinyalini, Cb ve Cr  ile ise chrominance (renk) bilgilerini saklayan bir renk uzayýdýr.
vid.FrameGrabInterval = 3; % videoda kaç frame'de bir görüntü alacaðýmýzý belirliyoruz.Default deðeri 1'dir. Fakat kamera özelliðine göre bu sýklýðý ayarlayabiliriz.

start(vid) % video'yu baþlatýyoruz.

while(vid.FramesAcquired<=200) % 100 frame yakaladýktan sonra döngüye girecek
    
    % Get the snapshot of the current frame
    data = getsnapshot(vid); % video'dan frame alýyor.
    
    % Now to track red objects in real time
    % we have to subtract the red component 
    % from the grayscale image to extract the red components in the image.
    diff_im = imsubtract(data(:,:,1), rgb2gray(data)); % resmin kýrmýzý renginden griyi çýkartýp aradaki fark elde edilir.
    %Use a median filter to filter out noise
    diff_im = medfilt2(diff_im, [3 3]);%gürültüyü engelliyor
    % Convert the resulting grayscale image into a binary image.
    diff_im = im2bw(diff_im,0.18); %0.18 deðeri parlaklýk eþiði için optimum deðerdir. 
    
    % Remove all those pixels less than 300px
    diff_im = bwareaopen(diff_im,300);% 300 pikselden küçük olan nesneleri algýlamýyor. Yani erosion iþleminin benzeridir.
    
    % Label all the connected components in the image.
    bw = bwlabel(diff_im, 8);%Resimde bulunan nesnelerin etiketlenmesi.
    
    % Here we do the image blob analysis.
    % We get a set of properties for each labeled region.
    stats = regionprops(bw, 'BoundingBox', 'Centroid'); % etiketlenmiþ nesnelerin konumunu belirler. 
    
    % Display the image
    imshow(data)
    
    hold on
    
    %This is a loop to bound the red objects in a rectangular box.
    for object = 1:length(stats)
        bb = stats(object).BoundingBox;
        bc = stats(object).Centroid;
        rectangle('Position',bb,'EdgeColor','r','LineWidth',2)
        plot(bc(1),bc(2), '-c+')
        a=text(bc(1)+15,bc(2), strcat('X: ', num2str(round(bc(1))), '    Y: ', num2str(round(bc(2)))));
        set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
    end
    
    hold off
end
% Both the loops end here.

% Stop the video aquisition.
stop(vid);

flushdata(vid);

clear all
