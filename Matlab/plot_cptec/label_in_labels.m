function label_already_in = label_in_labels(label, labels)
    label_already_in = false;
    for current_region = labels(~cellfun(@isempty, {labels.label}))
        current_label = str2double(current_region.label);

        if current_label == label
            label_already_in = true;
            break
        end

    end
end