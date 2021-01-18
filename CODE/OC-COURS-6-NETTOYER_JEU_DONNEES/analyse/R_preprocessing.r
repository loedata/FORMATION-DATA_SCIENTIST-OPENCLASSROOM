
data = read.csv("operations.csv")

colnames(data) = c('identifiant_transaction','date_operation','date_valeur',
                'libelle','debit','credit','solde')

most_common_words = function(labels){
    words = c()
    for(lab in labels){
        words = c(words,strsplit(lab," ")[[1]])
    }
    top = sort(table(words),decreasing=TRUE)[1:101]
    for(i in 1:length(top)){
        freq = top[i][[1]]
        word = names(top)[i]
        print(paste0('(',word,', ',freq,')'))
    }
}

most_common_words(data$libelle)

CATEGS = list(
    'LOYER'= 'LOYER',
    'FORFAIT COMPTE SUPERBANK'= 'COTISATION BANCAIRE',
    'LES ANCIENS ROBINSON'= 'COURSES',
    "L'EPICERIE DENBAS"= 'COURSES',
    'TELEPHONE'= 'FACTURE TELEPHONE',
    'LA CCNCF'= 'TRANSPORT',
    'CHEZ LUC'= 'RESTAURANT',
    'RAPT'= 'TRANSPORT',
    'TOUPTIPRI'= 'COURSES',
    'LA LOUVE'= 'COURSES',
    'VELOC'= 'TRANSPORT'
)

TYPES = list(
    'CARTE'= 'CARTE',
    'VIR'= 'VIREMENT',
    'VIREMENT'= 'VIREMENT',
    'RETRAIT'= 'RETRAIT',
    'PRLV'= 'PRELEVEMENT',
    'DON'= 'DON'
)

LAST_BALANCE = 2400 # Solde du compte APRES la dernière opération en date
EXPENSES = c(80,200) # Bornes des catégories de dépense : petite, moyenne et grosse
WEEKEND = c("Saturday","Sunday") # Jours non travaillés

# Controle des colonnes
for(c in c('date_operation','libelle','debit','credit'))
    if(!c %in% colnames(data))
        if((c %in% c('debit','credit') && !'montant' %in% colnames(data)) || ! c %in% c('debit','credit')){
            msg = "Il vous manque la colonne '%s'. Attention aux majuscules "
            msg = paste0(msg,"et minuscules dans le nom des colonnes!")
            stop(sprintf(msg,c))
        }


# Suppression des colonnes innutiles
for(c in colnames(data))
    if(! c %in% c('date_operation','libelle','debit','credit','montant'))
        data[c] = NULL

# Ajout de la colonne 'montant' si besoin
if(! 'montant' %in% colnames(data)){
    data[is.na(data$debit),"debit"] = 0 # on remplace les valeurs nulles par des 0
    data[is.na(data$credit),"credit"] = 0 # on remplace les valeurs nulles par des 0
    data["montant"] = data["debit"] + data["credit"]
    data["credit"] = NULL
    data["debit"] = NULL
}
        
# creation de la variable 'solde_avt_ope'
data$date_operation = as.Date(data$date_operation)
data = data[order(data$date_operation),]
amount = data["montant"]
balance = cumsum(amount)$montant
last_val = balance[length(balance)]
balance = c(0, balance[1:(length(balance)-1)])
balance = balance - last_val + LAST_BALANCE
data["solde_avt_ope"] = balance

# Assignation des operations a une categorie et a un type
detect_words = function(values, dictionary){
    result = c()
    for(lib in values){
        operation_type = "AUTRE"
        for(i in 1:length(dictionary)){
            val = dictionary[i]
            word = names(dictionary)[i]
            if(grepl(word,lib)){
                operation_type = val[[1]]
            }
        }
        result = c(result, operation_type)
    }
    return(result)
}
data["categ"] = detect_words(data$libelle, CATEGS)
data["type"] = detect_words(data$libelle, TYPES)
            
# creation des variables 'tranche_depense' et 'sens'
expense_slice = function(value){
    value = -value # Les dépenses sont des nombres négatifs
    if(value < 0){
        return("(pas une dépense)")
    }else if(value < EXPENSES[1]){
        return("petite")
    }else if(value < EXPENSES[2]){
        return("moyenne")
    }else{
        return("grosse")
    }
}
data["tranche_depense"] = apply(data["montant"], 1,FUN=expense_slice)
data["sens"] = apply(data["montant"], 1,FUN=(function(m) if(m>0){"credit"}else{"debit"}))

# Creation des autres variables
weekdays =  c('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday')
    
data["annee"] = apply(data["date_operation"], 1, FUN=function(d) as.integer(format(as.Date(d),"%Y"))) 
data["mois"]  = apply(data["date_operation"], 1, FUN=function(d) as.integer(format(as.Date(d),"%m"))) 
data["jour"]  = apply(data["date_operation"], 1, FUN=function(d) as.integer(format(as.Date(d),"%d"))) 
data["tmp"] = apply(data["date_operation"], 1, FUN=function(d) as.POSIXlt(as.Date(d))$wday)
data["jour_sem"] = apply(data["tmp"], 1, FUN=function(d) weekdays[d+1])
data["jour_sem_num"] = data["tmp"]
data["tmp"] = NULL
data["weekend"] = apply(data["jour_sem"], 1, function(j) j %in% WEEKEND)
data["quart_mois"] = apply(data["jour"], 1, function(jour) as.integer((jour-1)*4/31)+1 )

# Enregistrement au format CSV
write.csv(data,"operations_enrichies.csv",row.names=FALSE,quote=FALSE)


