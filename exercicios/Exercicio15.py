import gurobipy as gp
from gurobipy import GRB

centros, demanda = gp.multidict( #i
    {
        "Centro 1": [1000],
        "Centro 2": [600],
        "Centro 3": [700]
    }
)

bases, cap_capacidade = gp.multidict( #j
    {
        "Base 1": [1000],
        "Base 2": [800],
        "Base 3": [700],
    }
)

custo_transporte = { #ij
    ("Centro 1", "Base 1"): 200,
    ("Centro 1", "Base 2"): 200,
    ("Centro 1", "Base 3"): 300,
    ("Centro 2", "Base 1"): 300,
    ("Centro 2", "Base 2"): 400,
    ("Centro 2", "Base 3"): 220,
    ("Centro 3", "Base 1"): 300,
    ("Centro 3", "Base 2"): 400,
    ("Centro 3", "Base 3"): 250,
}

classe, custo_fixo, custo_var, q_capacidade, qtde_atrac, qtde_navios = gp.multidict( #k
    {
        "Pequeno": [5000, 2, 200, 2, 7],
        "Grande": [10000, 3, 500, 3, 5],
    }
)

rotas, visitadas, distancias, visita_base = gp.multidict(
    {
        "Rota 1": ["BN-B1-BN", 370, {"Base 1": 1, "Base 2": 0, "Base 3": 0}],
        "Rota 2": ["BN-B2-BN", 420, {"Base 1": 0, "Base 2": 1, "Base 3": 0}],
        "Rota 3": ["BN-B3-BN", 480, {"Base 1": 0, "Base 2": 0, "Base 3": 1}],
        "Rota 4": ["BN-B1-B2-BN", 550, {"Base 1": 1, "Base 2": 1, "Base 3": 0}],
        "Rota 5": ["BN-B1-B3-BN", 620, {"Base 1": 1, "Base 2": 0, "Base 3": 1}],
        "Rota 6": ["BN-B2-B3-BN", 680, {"Base 1": 0, "Base 2": 1, "Base 3": 1}],
        "Rota 7": ["BN-B1-B2-B3-BN", 720, {"Base 1": 1, "Base 2": 1, "Base 3": 1}],
    }
)

m = gp.Model()

x = m.addVars(centros, bases, vtype=GRB.INTEGER)
y = m.addVars(classe, rotas, vtype=GRB.INTEGER)
z = m.addVars(bases, classe, rotas, vtype=GRB.INTEGER)

c1 = m.addConstrs(
    gp.quicksum(x[i, j] for j in bases) == demanda[i] for i in centros
)

c2 = m.addConstrs(
    gp.quicksum(x[i,j] for i in centros) <= cap_capacidade[j] for j in bases
)

c3 = m.addConstrs(
    gp.quicksum(y[k, r] for r in rotas) <= qtde_navios[k] for k in classe
)

c4 = m.addConstrs(
    y[k, r] == 0
    for k in classe for r in rotas
    if all(visita_base[r][j] == 0 for j in bases)
)

c5 = m.addConstrs(
    gp.quicksum(visita_base[r][j] * z[j, k, r] for k in classe for r in rotas) ==
    gp.quicksum(x[i,j] for i in centros) 
    for j in bases
)

c6 = m.addConstrs(
    gp.quicksum(visita_base[r][j] * z[j, k, r] for j in bases) <= q_capacidade[k]*y[k,r] for k in classe for r in rotas
)

m.setObjective(
    gp.quicksum(custo_transporte[i, j] * x[i, j] for i in centros for j in bases)
    +
    gp.quicksum((custo_fixo[k] + custo_var[k]*distancias[r]) * y[k, r] 
                for k in classe for r in rotas),

    sense = GRB.MINIMIZE
)


m.optimize()
print("")

if m.status == GRB.OPTIMAL:
    print("Custo mínimo da operação será de R$ ", m.ObjVal)
    print("")
    for i, j in x.keys():
        if x[i, j].x > 0:
            print(f"Fluxo de {i} para {j}: {x[i, j].x}")
    print("")
    for k, r in y.keys():
        if y[k, r].x > 0:
            print(f"{r} usada pela classe {k}: {y[k, r].x}")