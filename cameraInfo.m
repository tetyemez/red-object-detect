function [camera_name, camera_id, resolution] = cameraInfo(hardwareInfo)
    % Donan�m bilgisine g�re kameran�n isminin, bilgilerinin, ��z�n�rl�k
    % de�erlerinin al�nmas�.
    camera_name = char(hardwareInfo.InstalledAdaptors(end));
    camera_info = imaqhwinfo(camera_name);
    camera_id = camera_info.DeviceInfo.DeviceID(end);
    resolution = char(camera_info.DeviceInfo.SupportedFormats(end-2));
    % Burada ��z�n�rl�k de�erlerinden sondan 2 �nceki de�er se�iliyor.
    % ��nk� kulland���m�z kamerada istenen ��z�n�rl�k (800x600) bu de�ere denk geliyor.
end