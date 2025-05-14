import gurobipy as gp
from gurobipy import GRB

qtde_minerios = 3
qtde_ligas = 2
qtde_metais = 5

vet_tonmax = [1000, 2000, 3000]
mat_comps = [
    [20, 10, 30, 30, 10],
    [10, 20, 30, 30, 10],
    [5, 5, 70, 20, 0],
]

vet_custo = [75, 90, 120]

props = [
    {'metal': 'Metal1', 'liga': 'Liga1', 'op': '<=', 'valor': 0.8},
    {'metal': 'Metal2', 'liga': 'Liga1', 'op': '<=', 'valor': 0.3},
    {'metal': 'Metal4', 'liga': 'Liga1', 'op': '>=', 'valor': 0.5},
    {'metal': 'Metal2', 'liga': 'Liga2', 'op': '<=', 'valor': 0.6},
    {'metal': 'Metal2', 'liga': 'Liga2', 'op': '>=', 'valor': 0.4},
    {'metal': 'Metal3', 'liga': 'Liga2', 'op': '>=', 'valor': 0.3},
    {'metal': 'Metal4', 'liga': 'Liga2', 'op': '<=', 'valor': 0.7},
]

vet_venda = [750, 600]
vet_processo = [120, 100, 110]
vet_fabrica = [150, 135]

minerios = list()
for i in range(qtde_minerios):
    minerios.append("Minerio{}".format(i+1))

metais = list()
for j in range(qtde_metais):
    metais.append("Metal{}".format(j+1))

ligas = list()
for k in range(qtde_ligas):
    ligas.append("Liga{}".format(k+1))

qtde_max = dict()
for idx, i in enumerate(minerios):
    qtde_max[i] = vet_tonmax[idx]

custo = dict()
for idx, i in enumerate(minerios):
    custo[i] = vet_custo[idx]

comps = dict()
for i in range(qtde_minerios):
    for j in range(qtde_metais):
        comps[minerios[i], metais[j]] = mat_comps[i][j]

venda = dict()
for idx, k in enumerate(ligas):
    venda[k] = vet_venda[idx]

processo = dict()
for idx, i in enumerate(minerios):
    processo[i] = vet_processo[idx]

fabrica = dict()
for idx, k in enumerate(ligas):
    fabrica[k] = vet_fabrica[idx]

m = gp.Model()

x = m.addVars(minerios, vtype=GRB.INTEGER)
w = m.addVars(ligas, vtype=GRB.INTEGER)
y = m.addVars(metais, ligas, vtype=GRB.INTEGER)

m.addConstrs(
    (
        x[i] <= qtde_max[i] for i in minerios
    )
)

m.addConstrs(
    w[k] == gp.quicksum(y[j, k] for j in metais)
    for k in ligas
)

m.addConstrs(
    y[j, k] <= comps[i, j] * x[i] for i in minerios
    for j in metais
    for k in ligas
)

for p in props:
    j = p['metal']
    k = p['liga']
    op = p['op']
    valor = p['valor']
    if op == '<=':
        m.addConstr(y[j, k] <= valor * w[k])
    elif op == '>=':
        m.addConstr(y[j, k] >= valor * w[k])
    elif op == '==':
        m.addConstr(y[j, k] == valor * w[k])

m.setObjective(
    (gp.quicksum(venda[k] * w[k] for k in ligas) - gp.quicksum(fabrica[k] * w[k] for k in ligas)) -
    (gp.quicksum(custo[i] * x[i] for i in minerios) + gp.quicksum(processo[i] * x[i] for i in minerios)),
    sense = GRB.MAXIMIZE
)


m.optimize()
print("Lucro será de R$", m.ObjVal)