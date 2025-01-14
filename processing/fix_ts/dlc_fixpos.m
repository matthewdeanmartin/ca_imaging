function f = dlc_fixpos(pos, timestamps, env_shape)
%put in 1 for rectangle, 2 for oval
%for fixing deeplabcut positions
%can import CSV from dlc and timestamps using: pos = readtable('file.csv');


pos = pos(3:end, 2:end);
pos = table2array(pos);
pos = cellfun( @str2double, pos );
posx  = pos(:,1);
posy = pos(:,2);

timestamps = table2array(timestamps);
timestamps = timestamps(:,2);



bad_light = find(pos(:,3)<.85); %bad light positions
for z=1:length(bad_light)
  if (pos(bad_light(z),6)>.85)
      posx(bad_light(z)) = pos(bad_light(z),4);
      posy(bad_light(z)) = pos(bad_light(z),5);
  else
    posx(bad_light(z)) = NaN;
    posy(bad_light(z)) = NaN;
  end
end


if env_shape == 1 %sq/rectangle. this is to set the bounds but the tracking seems good without so?
  bad_UR = find(pos(:,12)<.95); %bad upper right positions

  pos(bad_UR, 10) = NaN;
  pos(bad_UR, 11) = NaN;

  URx = nanmedian(pos(:, 10));
  URy = nanmedian(pos(:, 11));
  UR = [URx,URy];

  bad_UL = find(pos(:,15)<.95); %bad upper left positions
  pos(bad_UL, 13) = NaN;
  pos(bad_UL, 14) = NaN;

  ULx = nanmedian(pos(:, 13));
  ULy = nanmedian(pos(:, 14));
  UL = [ULx,ULy];

  bad_LL = find(pos(:,18)<.95); %bad lower left positions
  pos(bad_LL, 16) = NaN;
  pos(bad_LL, 17) = NaN;

  LLx = nanmedian(pos(:, 16));
  LLy = nanmedian(pos(:, 17));
  LL = [LLx,LLy];

  bad_LR = find(pos(:,21)<.95); %bad lower right positions
  pos(bad_LR, 19) = NaN;
  pos(bad_LR, 20) = NaN;

  LRx = nanmedian(pos(:, 16));
  LRy = nanmedian(pos(:, 17));
  LR = [LRx,LRy];

  %turns out v good tracking inside box so dont need so making it huge
  bottomy = max(median(URy), median(ULy))-500;
  topy = min(median(LRy), median(LLy))+500;
  leftx = min(median(ULx), median(LLx))-500;
  rightx = max(median(UR), median(LR))+500;
end




if env_shape == 2 %OVAL
bad_left = find(pos(:,12)<.95); %bad left positions

pos(bad_left, 10) = NaN;
pos(bad_left, 11) = NaN;

leftx = nanmedian(pos(:, 10));
lefty = nanmedian(pos(:, 11));
left = [leftx,lefty];

bad_right = find(pos(:,18)<.95); %bad right positions
pos(bad_right, 16) = NaN;
pos(bad_right, 17) = NaN;

rightx = nanmedian(pos(:, 16));
righty = nanmedian(pos(:, 17));
right = [rightx,righty];

bad_bottom = find(pos(:,15)<.95); %bad bottom positions
pos(bad_bottom, 13) = NaN;
pos(bad_bottom, 14) = NaN;

topx = nanmedian(pos(:, 13));
topy = nanmedian(pos(:, 14));
top = [topx,topy];


dif = ((righty+lefty)./2)-topy;
bottomx = topx;
bottomy = ((righty+lefty)./2)-abs(dif);
bottom = [bottomx,bottomy];

middlex = ((rightx+leftx)./2);
middley = (topy+bottomy)./2;


topy = topy-50;
bottomy = bottomy+50;
leftx = leftx+50;
rightx = rightx-50;
end


for k=1:length(posy) %checks for values outside arena bounds
  if ((posy(k)-topy)>0)
    posx(k) = NaN;
    posy(k) = NaN;

  elseif (bottomy-posy(k)>0)
    posx(k) = NaN;
    posy(k) = NaN;

  elseif ((leftx-posx(k))>0)
    posx(k) = NaN;
    posy(k) = NaN;

  elseif ((posx(k)-rightx)>0)
     posx(k) = NaN;
     posy(k) = NaN;
  end
end



%{
for k=1:length(pos)

  coord  = [pos(k,1), pos(k,2); leftx,lefty];
  dis1 = pdist(coord,'euclidean');
  coord  = [pos(k,1), pos(k,2); rightx,righty];
  dis2 = pdist(coord,'euclidean');
  coord  = [pos(k,1), pos(k,2); bottomx,bottomy];
  dis3 = pdist(coord,'euclidean');
  coord  = [pos(k,1), pos(k,2); topx,topy];
  dis4 = pdist(coord,'euclidean');
  coord  = [pos(k,1), pos(k,2); middlex, middley];
  dis5 = pdist(coord,'euclidean');
  if dis1>100 && dis2>100 && dis3>100 && dis4>100  & dis5>100
    pos(k, 1) = NaN;
    pos(k, 2) = NaN;
  end
end
%}




%time = file(1, :);
pos = [posx,posy];

pos = inpaint_nans(pos, 2);



xpos = (pos(:, 1));
%xpos = filloutliers(xpos, 'pchip', 'movmedian',30);
xpos =  smoothdata(xpos, 'gaussian', 15);
ypos = (pos(:, 2));
%ypos = filloutliers(ypos, 'pchip', 'movmedian',30);
ypos =  smoothdata(ypos, 'gaussian', 15);
timestamps = timestamps/1000;
pos = [timestamps, xpos, ypos];
f = pos;
