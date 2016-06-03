# qucit-challenge

Le but du jeu c'est de faire un modèle qui va prédire l'occupation des stations. Attention, quel que soit le modèle il ne peut pas utiliser de données futures, ni dans ses features ni pour son entraînement. C'est à dire que si tu veux prédire le nombre de vélos dans une station pour le 18 mars 2015 à 17h, ton modèle ne doit jamais avoir vu de données postérieures à cette date. L'horizon de temps considéré est de une heure, et pour évaluer tes modèles tu pourras utiliser deux modèles benchmarks : 

- le modèle statique : V_s(t+tau) = V_s(t) 
- le modèle « incrément moyen » : V_s(t+tau) = V_s(t) + increment_moyen( s, h(t), tau )

tau (= 1heure ici) est l’horizon de temps de la prédiction

V_s(t) = nombre de vélos, station s à l’instant t

Increment_moyen(s, h, tau) = < V_s(t + tau) - V_s(t) > où la moyenne est prise sur l’ensemble des t tels que h(t) = h. En pratique h peut être l’heure mesurée sur une semaine type, par exemple "lundi à 9h du matin"

Pour ce benchmark aussi il s’agit d’implémenter un modèle qui ne connaît que les données passées au moment où il réalise ses prédictions (c’est trop facile de prédire le futur sinon). Donc pour ça chaque semaine tu recalcules la moyenne. Par exemple, quand tu veux prédire le nombre de vélos qui vont arriver (ou repartir si c’est négatif) entre le lundi 8 février 2016 15h et le lundi 8 février 2016 16h, tu regardes tous les lundi précédents entre 15h et 16h pour lesquels tu as des données et tu calcules la moyenne de l’incrément. Et ensuite tu arrondis à l’entier le plus proche.

Idem pour ton modèle maison : il n’a le droit d’utiliser que les données passées pour faire ses prédictions et il doit aussi produire un nombre entier de vélos.

Ce sont les benchmarks qu'on utilise nous aussi, on compare la Root Mean Square Error de nos modèles à celle de ces modèles.
On prend la RMSE sur l'ensemble du jeu de données. Donc pour le modèle statique il y a une valeur exacte, mettons par exemple que ce soit 5.43210 vélos de RMSE, ce qui nous permet de vérifier que ton benchmark est correct.




La variable à prédire est l'incrément à t+1h
