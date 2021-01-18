###############################################################################
# TP : Prévoyez une série à l'aide des méthodes de lissage exponentiel
###############################################################################

# Si on souhaite prévoir la série airpass à l'aide du lissage exponentiel simple, 
# on peut utiliser les commandes suivantes :
les=ets(y,model="ANN")
les.pred=predict(les,12)
plot(les.pred)

# Pour le lissage exponentiel double :
led=ets(x,model="MMN")
led.pred=predict(led,12)
plot(led.pred)

# Et enfin pour la méthode de Holt-Winters :
hw=ets(x,model="MMM")
hw.pred=predict(hw,12)
plot(hw.pred)