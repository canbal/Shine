names = {'Art', 'Books', 'Dolls', 'Flowerpots', 'Laundry'...
    'Bowling2', 'Midd1', 'Moebius', 'Monopoly', 'Reindeer', 'Rocks1'};

qualities = 5:5:25;

for i = 1:length(names)
        
    seq = names{i};
    
    for q = qualities
            
        mainProcessShine(names{i}, q)
        
    end
    
end

disp('Everything is processed!');