function ret = weight(val)
    if(val(:,:,1) == 0 && val(:,:,2) == 0 && val(:,:,3) == 0)
       ret = 0;
    else
        ret = 1;
    end
end

