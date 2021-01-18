###############################################################################
# TP : Prévoyez une série temporelle à l’aide des méthodes SARIMA
###############################################################################

#######################################################
# Stationnarisation de la série

# On désigne par Xt  la série airpass, et on considère Yt=ln(Xt) . On travaille en effet 
# sur le logarithme de la série afin de pallier l’accroissement de la saisonnalité. On passe 
# ainsi d’un modèle multiplicatif à un modèle additif.
plot(acf(y,lag.max=36,plot=FALSE),ylim=c(-1,1))

# La sortie ACF présente une décroissance lente vers 0, ce qui traduit un problème de non-stationnarité. 
# On effectue donc une différenciation (I−B) .
y_dif1=diff(y,lag=1,differences=1)
plot(acf(y_dif1,lag.max=36,plot=FALSE),ylim=c(-1,1))

#  La sortie ACF de la série ainsi différenciée présente encore une décroissance lente vers 0 pour les 
# multiples de 12. On effectue cette fois la différenciation (I−B^12) .
y_dif_1_12=diff(y_dif1,lag=12,differences=1)
plot(acf(y_dif_1_12,lag.max=36,plot=FALSE),ylim=c(-1,1))


#######################################################
# Identification, estimation et validation de modèles

# On s’appuie sur les autocorrélogrammes simple et partiels estimés
y_dif_1_12=diff(y_dif1,lag=12,differences=1)
plot(acf(y_dif_1_12,lag.max=36,plot=FALSE),ylim=c(-1,1))

plot(pacf(y_dif_1_12,lag.max=36,plot=FALSE),ylim=c(-1,1))


#######################################################
# Modèle 1

# On estime en premier lieu un modèle SARIMA(1,1,1)(1,1,1)12  au vu des autocorrélogrammes 
# empiriques simples et partiels.

model1=Arima(y,order=c(1,1,1),list(order=c(1,1,1),period=12),include.mean=FALSE,method="CSS-ML")
summary(model1)

t_stat(model1)

Box.test.2(model1$residuals,nlag=c(6,12,18,24,30,36),type="Ljung-Box",decim=5)
# Ce modèle ayant des paramètres non significatifs, on en teste un second.


#######################################################
# Modèle 2

model2=Arima(y,order=c(1,1,1),list(order=c(0,1,1),period=12),include.mean=FALSE,method="CSS-ML")
summary(model2)

t_stat(model2)

Box.test.2(model2$residuals,nlag=c(6,12,18,24,30,36),type="Ljung-Box",decim=5)
# Ce modèle ayant des paramètres non significatifs, on en teste un troisième.


#######################################################
# Modèle 3

model3=Arima(y,order=c(0,1,1),list(order=c(0,1,1),period=12),include.mean=FALSE,method="CSS-ML")
summary(model3)

t_stat(model3)

Box.test.2(model3$residuals,nlag=c(6,12,18,24,30,36),type="Ljung-Box",decim=5)

# Les tests de significativité des paramètres et de blancheur du résidu sont validés au niveau 5%.
shapiro.test(model3$residuals)
# Le test de normalité est également validé pour ce modèle.


#######################################################
# Prévision à l’aide du modèle retenu (3) de l’année 1961

pred_model3=forecast(model3,h=12,level=95)
pred=exp(pred_model3$mean)
pred_l=ts(exp(pred_model3$lower),start=c(1961,1),frequency=12)
pred_u=ts(exp(pred_model3$upper),start=c(1961,1),frequency=12)
ts.plot(x,pred,pred_l,pred_u,xlab="t",ylab="Airpass",col=c(1,2,3,3),lty=c(1,1,2,2),lwd=c(1,3,2,2))

ts.plot(window(x,start=c(1960,1)),pred,pred_l,pred_u,xlab="t",ylab="Airpass",col=c(1,2,3,3),lty=c(1,1,2,2),lwd=c(1,3,2,2))


#######################################################
# Analyse a posteriori

# On tronque la série de l’année 1960, qu’on cherche ensuite à prévoir à partir de l’historique 1949-1959.
x_tronc=window(x,end=c(1959,12))
y_tronc=log(x_tronc)
x_a_prevoir=window(x,start=c(1960,1))

# On vérifie que le modèle 3 sur la série tronquée est toujours validé.
model3tronc=Arima(y_tronc,order=c(0,1,1),list(order=c(0,1,1),period=12),include.mean=FALSE,method="CSS-ML")
summary(model3tronc)

t_stat(model3tronc)

Box.test.2(model3tronc$residuals,nlag=c(6,12,18,24,30,36),type="Ljung-Box",decim=5)

shapiro.test(model3tronc$residuals)

# On constate que la réalisation 1960 est dans l’intervalle de prévision à 95% (basé sur les données 
# antérieures à 1959).
pred_model3tronc=forecast(model3tronc,h=12,level=95)
pred_tronc=exp(pred_model3tronc$mean)
pred_l_tronc=ts(exp(pred_model3tronc$lower),start=c(1960,1),frequency=12)
pred_u_tronc=ts(exp(pred_model3tronc$upper),start=c(1960,1),frequency=12)
ts.plot(x_a_prevoir,pred_tronc,pred_l_tronc,pred_u_tronc,xlab="t",ylab="Airpass",col=c(1,2,3,3),lty=c(1,1,2,2),lwd=c(3,3,2,2))
legend("topleft",legend=c("X","X_prev"),col=c(1,2,3,3),lty=c(1,1),lwd=c(3,3))
legend("topright",legend=c("int95%_inf","int95%_sup"),col=c(3,3),lty=c(2,2),lwd=c(2,2))

# On calcule les RMSE et MAPE.
rmse=sqrt(mean((x_a_prevoir-pred_tronc)^2))
rmse

mape=mean(abs(1-pred_tronc/x_a_prevoir))*100
mape