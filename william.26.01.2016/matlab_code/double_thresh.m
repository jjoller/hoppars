function state=double_thresh(data,upperthreshold,lowerthreshold)
%state=double_thresh(data,upperthreshold,lowerthreshold)
%upperthreshold upperthreshold
%lowerthreshold lowerthreshold
%performs a schmidt trigger operation on data, state will stay low until
%data crosses above the upperthreshold, then will stay high until it falls
%below the lowerthreshold

state=zeros(1,length(data));
state(1)=0;

for i=2:length(data)
    state(i)=state(i-1);
    if state(i-1)==0
        if data(i)>upperthreshold
            state(i)=1;
        end
    else
        if data(i)<lowerthreshold
            state(i)=0;
        end
    end
end

