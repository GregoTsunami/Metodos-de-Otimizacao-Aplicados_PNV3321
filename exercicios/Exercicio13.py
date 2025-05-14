import gurobipy as gp
from gurobipy import GRB

usinas, capacidade, custo_constru, custo_oper = gp.multidict(
    {
        "Usina 1": [70, 20, 1.5],
        "Usina  2": [50, 16, 0.8],
        "Usina 3": [60, 18, 1.3],
        "Usina 4": [40, 14, 0.6],
    }
)

ano, demanda = gp.multidict(
    {
        1: 80,
        2: 100,
        3: 120,
        4: 140,
        5: 160,
    }
)

m = gp.Model()

x = m.addVars(usinas, ano, vtype=GRB.BINARY) # se for aberta
y = m.addVars(usinas, ano, vtype=GRB.BINARY) # se estiver funfando

c1 = m.addConstrs(
    gp.quicksum(capacidade[i] * y[i, t] for i in usinas) >= demanda[t] for t in ano
)

c2 = m.addConstrs(
    y[i,t] == gp.quicksum(x[i,t] for t in ano) for i in usinas for t in ano
)

m.setObjective(
    gp.quicksum(
        custo_constru[i] * x[i, t] + custo_oper[i] * y[i, t] for i in usinas for t in ano
    ),
    sense = GRB.MINIMIZE,
)

m.optimize()
print("")
print("O custo é de: R$ ", round(m.ObjVal*10**6))
print("")

for i in usinas:
    for t in ano:
        if y[i, t].X > 0.5:
            print(f"{i} estará funcionando no ano {t}")
    print("")