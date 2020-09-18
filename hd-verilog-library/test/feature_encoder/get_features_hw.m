function [features] = get_features_hw(allData, windowSize, featureFunc, meanWindow)
    raw_file = fopen('raw_input_vec.txt','w');
    feat_file = fopen('feat_output_vec.txt','w');
    numGestures = size(allData,1);
    numTrials = size(allData,2);
    features = struct([]);
    for g = 2:2%numGestures
        for tr = 1:1%numTrials
            data = allData(g,tr).raw;
            label = select_data(allData(g,tr).label);
            ind = find(label ~= 0);

            ind = [(ind(1)-windowSize):(ind(1)-1), ind];

            data = data(ind,:);
            label = label(ind);
            
            numWin = floor(length(ind)/windowSize);
            numChannels = size(data,2);
            
            val = zeros(numChannels,numWin);
            featLabel = zeros(numWin,1);

            buffer = zeros(meanWindow,numChannels);
            means = zeros(1,numChannels);
            idx = 1;
            meanIdx = 1;
            feat = zeros(1,numChannels);
            w = 1;
            for i = 1:length(ind)
                fprintf(raw_file,'%s\n',(dec2bin(fliplr(data(i,:)),15))');
                feat = feat + abs(data(i,:) - floor(means./meanWindow));
                means = means - buffer(meanIdx,:);
                means = means + data(i,:);
                buffer(meanIdx,:) = data(i,:);
                if idx == windowSize
                    idx = 1;
                    val(:,w) = floor(feat/32)';
                    featLabel(w) = label(i);
                    feat = zeros(1,64);
                    w = w + 1;
                else
                    idx = idx + 1;
                end
                
                if meanIdx == meanWindow
                    meanIdx = 1;
                else
                    meanIdx = meanIdx + 1;
                end
            end

            % for i = 1:numWin
            %     featLabel(i) = mode(label((1:windowSize)+(i-1)*windowSize));
            %     for ch = 1:numChannels
            %         val(ch,i) = featureFunc(data((1:windowSize)+(i-1)*windowSize,ch));
            %     end
            % end
%             val = val(:,2:end);
            val(val > 63) = 63;
%             featLabel = featLabel(2:end);
           	features(g,tr).values = val';
            features(g,tr).label = featLabel;
            for i = 1:numWin
                fprintf(feat_file,'%s\n',(dec2bin(fliplr(val(:,i)),6))');
            end
        end
    end
    fclose(raw_file);
    fclose(feat_file);
    
end