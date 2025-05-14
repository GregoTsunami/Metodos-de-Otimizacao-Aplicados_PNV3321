import gurobipy as gp
from gurobipy import GRB

nutriente, valor_diario = gp.multidict(
    {
        "calorias": 2400,
        "proteinas": 90,
        "calcio": 1000,
        "vitaminas": 500,
    }
)

comidas, custo = gp.multidict(
    {
        "pao": 8,
        "carne": 30,
        "batata": 5,
        "legumes": 8,
        "leite": 2.5,
    }
)

valor_nutricional = {
    ("pao", "calorias"): 2700,
    ("pao", "proteinas"): 85,
    ("pao", "calcio"): 60,
    ("pao", "vitaminas"): 0,
    ("carne", "calorias"): 1400,
    ("carne", "proteinas"): 200,
    ("carne", "calcio"): 90,
    ("carne", "vitaminas"): 0,
    ("batata", "calorias"): 705,
    ("batata", "proteinas"): 18,
    ("batata", "calcio"): 95,
    ("batata", "vitaminas"): 160,
    ("legumes", "calorias"): 100,
    ("legumes", "proteinas"): 9,
    ("legumes", "calcio"): 310,
    ("legumes", "vitaminas"): 1500,
    ("leite", "calorias"): 690,
    ("leite", "proteinas"): 35,
    ("leite", "calcio"): 1180,
    ("leite", "vitaminas"): 100,
}

m = gp.Model()

x = m.addVars(comidas, vtype=GRB.INTEGER)

m.setObjective(x.prod(custo), GRB.MINIMIZE)

c = m.addConstrs(
    (
        gp.quicksum(valor_nutricional[j, i] * x[j] for j in comidas) >= valor_diario[i]
        for i in nutriente
    )
)
m.optimize()

if m.status == GRB.OPTIMAL:
    print("Solução Otimizada:")
    for j in comidas:
        if x[j].X > 0:
            print(f"{j}: {int(x[j].X)} porções")
    print("Total: R$", m.objVal)
else:
    print("Sem solução")