import gurobipy as gp
from gurobipy import GRB

qtde_projs = 6
qtde_anos = 4

vet_recursos = [60, 70, 35, 20]
vet_lucro = [32.40, 35.80, 17.75, 14.80, 18.20, 12.35]

mat_desembolso = [
    [10.5, 14.4, 2.2, 2.4],
    [8.3, 12.6, 9.5, 3.1],
    [10.2, 14.2, 5.6, 4.2],
    [7.2, 10.5, 7.5, 5.0],
    [12.3, 10.1, 8.3, 6.3],
    [9.2, 7.8, 6.9, 5.1]
]

# listas
projs = list()
for i in range(qtde_projs):
    projs.append("Proj{}".format(i+1))

anos = list()
for j in range(qtde_anos):
    anos.append("Ano{}".format(j+1))

# dicionario
lucro = dict()
for i in range(qtde_projs):
    lucro[projs[i]] = vet_lucro[i]

recursos = dict()
for j in range(qtde_anos):
    recursos[anos[j]] = vet_recursos[j]

desembolso = dict()
for i in range(qtde_projs):
    for j in range(qtde_anos):
        desembolso[projs[i], anos[j]] = mat_desembolso[i][j]

# modelo
m = gp.Model()

# variaveis
x = m.addVars(projs, vtype=GRB.BINARY)

# fun obj
m.setObjective(gp.quicksum(lucro[i] * x[i] for i in projs), GRB.MAXIMIZE)

# restr
#c1 = m.addConstr((gp.quicksum(desembolso[i, j] * x[i] for i in projs) <= recursos[j] for j in anos))
c1 = 10.5*x["Proj1"] + 8.3*x["Proj2"] + 10.2*x["Proj3"] + 7.2*x["Proj4"] + 12.3*x["Proj5"] + 9.2*x["Proj6"] <= 60
c2 = 14.4 * x["Proj1"] + 12.6 * x["Proj2"] + 14.2 * x["Proj3"] + 10.5 * x["Proj4"] + 10.1 * x["Proj5"] + 7.8 * x["Proj6"] <= 70
c3 = 2.2 * x["Proj1"] + 9.5 * x["Proj2"] + 5.6 * x["Proj3"] + 7.5 * x["Proj4"] + 8.3 * x["Proj5"] + 6.9 * x["Proj6"] <= 35
c4 = 2.4 * x["Proj1"] + 3.1 * x["Proj2"] + 4.2 * x["Proj3"] + 5.0 * x["Proj4"] + 6.3 * x["Proj5"] + 5.1 * x["Proj6"] <= 20

# sol
m.optimize()
print("")
print("O maior lucro será de R$", m.ObjVal)
print("")
for i in projs:
    if x[i].X == 1:
        print(i, "foi escolhido com lucro de: ", lucro[i] * x[i].X)