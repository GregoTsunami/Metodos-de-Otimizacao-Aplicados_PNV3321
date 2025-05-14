import gurobipy as gp
from gurobipy import GRB

n_avioes = 3
n_rotas = 4

vet_cap = [40, 60, 100]
vet_qtde = [7, 8, 6]
vet_demanda = [650, 710, 610, 950]
mat_viaj = [
    [3,2,2,1],
    [4,3,3,2],
    [5,4,4,2]
]

mat_custo = [
    [1500, 1900, 2100, 2800],
    [2100, 2600, 2800, 3700],
    [3200, 3700, 3900, 5800]
]

avioes = list()
for i in range(n_avioes):
    avioes.append("Aeronave_{}".format(i+1))

rotas = list()
for j in range(n_rotas):
    rotas.append("Rota_{}".format(j+1))

capacidade = dict()
for idx, i in enumerate(avioes):
    capacidade[i] = vet_cap[idx]

quantidade = dict()
for idx, i in enumerate(avioes):
    quantidade[i] = vet_qtde[idx]

demanda = dict()
for idx, j in enumerate(rotas):
    demanda[j] = vet_demanda[idx]
    
viagens = dict()
for i in range(n_avioes):
    for j in range(n_rotas):
        viagens[avioes[i], rotas[j]] = mat_viaj[i][j]

custo = dict()
for i in range(n_avioes):
    for j in range(n_rotas):
        custo[avioes[i], rotas[j]] = mat_custo[i][j]

m = gp.Model()

x = m.addVars(avioes, rotas, vtype=GRB.INTEGER) #qtde de i alocada em j
y = m.addVars(avioes, rotas, vtype=GRB.INTEGER) #qtde de viag de i em j

c1 = m.addConstrs(
    (
        gp.quicksum(x[i, j] for j in rotas) <= quantidade[i] for i in avioes
    )
)

c2 = m.addConstrs(
    (
        gp.quicksum(x[i, j] for i in avioes) >= demanda[j] for j in rotas
    )
)

c3 = m.addConstrs(
    (
        y[i, j] <= viagens[i, j] for i in avioes
        for j in rotas
    )

)

c4 = m.addConstrs(
    y[i, j] >= 0 for i in avioes for j in rotas
)

c5= m.addConstrs(
    x[i, j] >= 0 for i in avioes for j in rotas
)

c6 = m.addConstrs(
    gp.quicksum(y[i, j] for j in rotas) <= capacidade[i] for i in avioes
)

c7 = m.addConstrs(
    x[i, j] <= y[i, j]*capacidade[i] for i in avioes for j in rotas
)

m.setObjective(
    gp.quicksum(custo[i, j] * y[i, j] for i in avioes for j in rotas),
    sense = GRB.MINIMIZE
)

m.optimize()
