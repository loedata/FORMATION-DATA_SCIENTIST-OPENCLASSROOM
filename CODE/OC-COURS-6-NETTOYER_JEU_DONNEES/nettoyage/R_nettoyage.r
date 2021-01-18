
data = read.csv("personnes.csv")
print(data)

lower_case = function(value){
    print(paste('Voici la valeur que je traite:', value))
    return(tolower(value))
}

data['prenom_min'] = apply(data['prenom'],1,lower_case)

data['prenom_min'] = NULL

VALID_COUNTRIES = c('France', "Côte d'ivoire", 'Madagascar', 'Bénin', 'Allemagne', 'USA')

check_country = function(country){
    if(! country %in% VALID_COUNTRIES){
        print(sprintf(' - "%s" n\'est pas un pays valide, nous le supprimons.',country))
        return(NA)
    }
    return (country)
}

first = function(str){
    str = str[[1]]
    parts = strsplit(str,',')[[1]]
    first_part = parts[1]
    if(length(parts) >= 2)
        print(sprintf(' - Il y a plusieurs parties dans "%s", ne gardons que %s.',paste(parts,collapse=""),first_part))  
    return(first_part)
}

convert_height = function(height){
    found = regmatches(height, regexpr("[[:digit:]]\\.[[:digit:]]{2}m", height)) 
    if(length(found)==0){
        print(paste(height, ' n\'est pas au bon format. Il sera ignoré.'))
        return(NA)
    }else{
        value = substring(height,1,nchar(height)-1) # on enlève le dernier caractère, qui est 'm'
        return(as.numeric(value))
    }
}

fill_height = function(height, replacement){
    if(is.na(height)){
        print(paste('Imputation par la moyenne :', replacement))
        return(replacement)
    }
    return(height)
}

data['email'] = apply(data['email'], 1, first)
data['pays'] = apply(data['pays'], 1, check_country)
data['taille'] = apply(data['taille'],1,convert_height) 
data['taille'] = apply(data['taille'], 1, function(t) if(!is.na(t) & t<3){t}else{NA})

mean_height = mean(as.numeric(data$taille), na.rm=TRUE)
for(i in 1:nrow(data))
    data[i,'taille'] = fill_height(data[i,'taille'], mean_height)
data["date_naissance"] = as.Date(data$date_naissance , "%d/%m/%Y")

data


