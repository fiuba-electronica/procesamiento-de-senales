video_name = 'rawseeds_indoor_1_5043_15FPS.avi';

movie = VideoWriter( sprintf('%s/%s','videos', video_name));
movie.FrameRate = 15;

open(movie)
for i=1:5043
    % if mod(i,2)==0
    fid = fopen(sprintf( '%s/image%06d.fig', 'figures', i), 'r');
    if (fid~=-1)
        h = openfig(sprintf( '%s/image%06d.fig', 'figures', i) );
        im = getframe(gcf);
        writeVideo(movie, im);
        i
        fclose(fid);
        close(h);
    end 
    % end
end
close(movie);

