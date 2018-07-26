clc;
clear all;
a = imaqhwinfo;
[camera_name, camera_id, format] = getCameraInfo(a);


% Capture the video frames using the videoinput function
% You have to replace the resolution & your installed adaptor name.
vid = videoinput(camera_name, camera_id, format);

% Set the properties of the video object
set(vid, 'FramesPerTrigger', Inf);
set(vid, 'ReturnedColorspace', 'rgb') % hangi g�r�nt� uzay�nda �al��aca��m�z� belirliyoruz. video buna g�re ayarl�yoruz. biz renk tabanl� nesne takibi yapaca��m�z i�in rgb renk uzay�na ayrl�yoruz.
%rgb uzay�nda belirledi�imizde: k�rm�z� ye�il ve mavi renge g�re i�lem
%yapabiliyoruz.�rne�in:  YCbCr  Y ile luminance (parlakl�k) sinyalini, Cb ve Cr  ile ise chrominance (renk) bilgilerini saklayan bir renk uzay�d�r.
vid.FrameGrabInterval = 3; % videoda ka� frame'de bir g�r�nt� alaca��m�z� belirliyoruz.Default de�eri 1'dir. Fakat kamera �zelli�ine g�re bu s�kl��� ayarlayabiliriz.

start(vid) % video'yu ba�lat�yoruz.

while(vid.FramesAcquired<=200) % 100 frame yakalad�ktan sonra d�ng�ye girecek
    
    % Get the snapshot of the current frame
    data = getsnapshot(vid); % video'dan frame al�yor.
    
    % Now to track red objects in real time
    % we have to subtract the red component 
    % from the grayscale image to extract the red components in the image.
    diff_im = imsubtract(data(:,:,1), rgb2gray(data)); % resmin k�rm�z� renginden griyi ��kart�p aradaki fark elde edilir.
    %Use a median filter to filter out noise
    diff_im = medfilt2(diff_im, [3 3]);%g�r�lt�y� engelliyor
    % Convert the resulting grayscale image into a binary image.
    diff_im = im2bw(diff_im,0.18); %0.18 de�eri parlakl�k e�i�i i�in optimum de�erdir. 
    
    % Remove all those pixels less than 300px
    diff_im = bwareaopen(diff_im,300);% 300 pikselden k���k olan nesneleri alg�lam�yor. Yani erosion i�leminin benzeridir.
    
    % Label all the connected components in the image.
    bw = bwlabel(diff_im, 8);%Resimde bulunan nesnelerin etiketlenmesi.
    
    % Here we do the image blob analysis.
    % We get a set of properties for each labeled region.
    stats = regionprops(bw, 'BoundingBox', 'Centroid'); % etiketlenmi� nesnelerin konumunu belirler. 
    
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
