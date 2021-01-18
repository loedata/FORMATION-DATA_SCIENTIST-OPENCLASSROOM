###############################################################################
# TP : représentez des séries temporelles
###############################################################################


# Série sunspot : nombre annuel de tâches solaires de 1790 à 1970
plot(sunspot.year,xlab="t",ylab="Sunspots")

# Bruit blanc gaussien de loi N(0,3^2)
# Pour les simulations effectuées dans ce document, on fixe arbitrairement la racine (seed) à 1789.
set.seed(1789)
plot(ts(rnorm(100,sd=3),start=1,end=100),xlab="t",ylab="Bruit blanc gaussien de variance 9")
abline(h=0)

# Série uspop : population des Etats-Unis, en millions, de 1790 à 1990 (Pas de temps décennal)
plot(uspop,xlab="t",ylab="Uspop")

# Série airpass : nombre mensuel de passagers aériens, en milliers, de janvier 1949 à décembre 1960
# Série brute :
plot(AirPassengers,xlab="t",ylab="Airpass")
# Logarithme de la série airpass
plot(log(AirPassengers),xlab="t",ylab="Airpass")

# Série beer : production mensuelle de bière en Australie, en mégalitres, de janvier 1956 à aout 1995
beer=read.csv("../Data/beer.csv",header=F,dec=".",sep=",")
beer=ts(beer[,2],start=1956,freq=12)
plot(beer,xlab="t",ylab="Beer")

# Série lynx : nombre annuel de lynx capturés au Canada, de 1821 à 1934
plot(lynx,xlab="t",ylab="Lynx")


# Sauf mention contraire, on travaillera dans la suite du cours sur la série temporelle airpass. 
# On la stockera sous la variable x, et son logarithme sous la variable y :
x=AirPassengers
y=log(x)