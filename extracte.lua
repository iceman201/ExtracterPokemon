-- split each component from table write into a text file
function writeToFile(tableName, fileName)
    local content = table.concat(tableName, "\n");
    local icon_name_txt = io.open(fileName, "w");
    icon_name_txt:write(content);
    icon_name_txt:flush();
    icon_name_txt:close();
end

-- get the icon name from html file
function getIconNameList(htmlString)
    local icon_name_txt_content = {};
    local matchIterator = string.gmatch(htmlString, "(%d+.?.?MS).png");

    for matchedStr in matchIterator do
        table.insert(icon_name_txt_content, matchedStr);
    end

    return icon_name_txt_content;
end

-- get the pokemon list from html file
function getPokemonNameList(htmlString)
    local pokemon_name_txt_content = {};
    matchIterator = string.gmatch(htmlString, "<span style=\"color:#000;\">([%w%p♂♀é]+)</span></a>");

    local isNeededConcat = false;   -- Concat content
    local concatTable = {"Unown_", ""}; 

    for matchedStr in matchIterator do
        if isNeededConcat == true then
            concatTable[2] = matchedStr;
            matchedStr = table.concat(concatTable);
            table.insert(pokemon_name_txt_content, matchedStr);
            isNeededConcat = false;
        elseif matchedStr == "Unown" then
            isNeededConcat = true;
        else
            table.insert(pokemon_name_txt_content, matchedStr);
        end
    end

    return pokemon_name_txt_content;
end

-- Generate bash command for first 1~770
function generateBash(iconNameList, pokemonNameList)
    local concatTable = {"cp ./icon_origin/\"", "", ".png\" ./icon_renamed/\"", "", ".png\""};
    local bashTable = {};
    for index = 1,770,1 do
        concatTable[2] = iconNameList[index];
        concatTable[4] = pokemonNameList[index].."-"..iconNameList[index];
        table.insert(bashTable, table.concat(concatTable));
    end
    return bashTable;
end

-- Main function
function main()
    -- Open pokemon.html get all content
    local pokemon_html = io.open("pokemon.html", "r");
    local pokemon_html_content = pokemon_html:read("*a");

    --Icon
    local icon_name_txt_content = getIconNameList(pokemon_html_content);
    
    --pokemon name
    local pokemon_name_txt_content = getPokemonNameList(pokemon_html_content);

    --generate bash command
    local rename_all_icon_sh_content = generateBash(
                                            icon_name_txt_content, 
                                            pokemon_name_txt_content
                                        );

    --write into each files
    writeToFile(icon_name_txt_content, "icon_name.txt");
    writeToFile(pokemon_name_txt_content, "pokemon_name.txt");
    writeToFile(rename_all_icon_sh_content, "rename_all_icon.sh");
end

main();
