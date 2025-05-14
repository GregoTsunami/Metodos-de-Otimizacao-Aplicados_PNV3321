import gurobipy as gp
from gurobipy import GRB

# m regioes
# n locais candidatos
# MIN custo de instalaçao
# cada região pode ser atendida num tempo T

m = 20 # regioes
n = 10 # candidatos
tempo = 30 # min

mat_tempo = [
    [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 6, 12, 18, 24, 30, 36, 42, 48],
    [6, 12, 18, 24, 30, 36, 42, 48, 54, 5, 11, 17, 23, 29, 35, 41, 47, 53, 5, 11],
    [7, 14, 21, 28, 35, 42, 49, 6, 13, 20, 27, 34, 41, 48, 55, 5, 12, 19, 26, 33],
    [8, 16, 24, 32, 40, 48, 56, 6, 14, 22, 30, 38, 46, 54, 6, 15, 23, 31, 39, 47],
    [9, 18, 27, 36, 45, 54, 6, 15, 24, 33, 42, 51, 6, 16, 25, 34, 43, 52, 6, 17],
    [10, 20, 30, 40, 50, 60, 11, 21, 31, 41, 51, 6, 17, 27, 37, 47, 57, 6, 18, 28],
    [11, 22, 33, 44, 55, 6, 17, 28, 39, 50, 6, 18, 29, 40, 51, 6, 19, 30, 41, 52],
    [12, 24, 36, 48, 6, 18, 30, 42, 54, 6, 19, 31, 43, 55, 6, 20, 32, 44, 56, 6],
    [13, 26, 39, 52, 6, 19, 32, 45, 58, 6, 20, 34, 48, 6, 22, 36, 50, 6, 24, 38],
    [14, 28, 42, 56, 6, 20, 34, 48, 6, 22, 36, 50, 6, 24, 38, 52, 6, 26, 40, 54]
]

matriz_a = [
    [1 if i <= tempo else 0 for i in linha] 
    for linha in mat_tempo
]


# listas
candidatos = list()
for i in range(n):
    candidatos.append("Candidato_{}".format(i+1))

regioes = list()
for j in range(m):
    regioes.append("Região_{}".format(j+1))

# dicionarios
a = dict()
for i in range(n):
    for j in range(m):
        a[candidatos[i], regioes[j]] = matriz_a[i][j]

# modelo
m = gp.Model()

# vars dec
x = m.addVars(candidatos, vtype = GRB.BINARY)

# restr
c1 = m.addConstrs(
    gp.quicksum(a[i,j]*x[i] for i in candidatos) >= 1 for j in regioes
)

# fun obj
m.setObjective(
    gp.quicksum(x[i] for i in candidatos),
    sense = GRB.MINIMIZE
)

m.optimize()
print("")
print("O custo mínimo das instalações é R$", m.ObjVal)
print("")
for i in candidatos:
    if x[i].X == 1:
        print(i, "recebe o posto de bombeiros")