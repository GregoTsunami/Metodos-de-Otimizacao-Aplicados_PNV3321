import gurobipy as gp
from gurobipy import GRB

faixa_hora, demanda, n_horas = gp.multidict( #t
    {
        "0h00 - 6h00": [15000, 6],
        "6h00 - 9h00": [30000, 3],
        "9h00 - 15h00": [25000, 6],
        "15h00 - 18h00": [40000, 3],
        "18h00 - 24h00": [27000, 6],
    }
)

gerador, qtde_ger, nivel_min, nivel_max, custo_ligar, custo_hor_nivmin, custo_hor_add = gp.multidict( #i
    {
        "Tipo 1": [12, 850, 2000, 2000, 1000, 2.0],
        "Tipo 2": [10, 1250, 1750, 1000, 2600, 1.3],
        "Tipo 3": [5, 1500, 4000, 500, 3000, 3.0],
    }
)

m = gp.Model()

x = m.addVars(gerador, faixa_hora, vtype=GRB.INTEGER) #qtde ger lig
y = m.addVars(gerador, faixa_hora, vtype = GRB.INTEGER) #qtde ger deslig
z = m.addVars(gerador, faixa_hora, vtype = GRB.INTEGER) #qtde ger operando
w = m.addVars(gerador, faixa_hora, vtype = GRB.INTEGER) #nivel medio de pot

c1 = m.addConstrs(
    z[i, t] <= qtde_ger[i] for i in gerador for t in faixa_hora
)

c2 = m.addConstrs(
    z[i, t] == z[i, t-1] - y[i, t-1] + x[i, t]
    for i in gerador for t in faixa_hora if i and t in [2,3,4,5]
)

c3 = m.addConstrs(
    w[i,t] >= nivel_min[i] * z[i,t] for i in gerador for t in faixa_hora
)

c4 = m.addConstrs(
    w[i, t] <= nivel_max[i] * z[i, t] for i in gerador for t in faixa_hora
)

c5 = m.addConstrs(
    gp.quicksum(w[i,t] for i in gerador) >= demanda[t] for t in faixa_hora
)

m.setObjective(
    gp.quicksum(custo_ligar[i]*x[i,t] +  custo_hor_nivmin[i]*n_horas[t]*z[i,t] + custo_hor_add[i]*n_horas[t]*(w[i, t]-(nivel_min[i]*z[i,t])) for i in gerador for t in faixa_hora) 
)

m.optimize()
print("-------------------"*10)

if m.status == GRB.OPTIMAL:
    print("O custo mínimo de operação será de: R$ ", m.ObjVal)
    print("")
    for i in gerador:
        for t in faixa_hora:
            if z[i, t].X != 0:
                print(f"Gerador do {i}, no horário das {t} terá {z[i, t].x} operando num nível de {w[i, t].x} MW")
        print("")
