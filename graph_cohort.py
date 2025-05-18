import matplotlib.pyplot as plt
import pandas as pd

# Read the CSV file
df = pd.read_csv('./data/extraido/century_cohort_analysis.csv')
plt.figure(figsize=(12, 6))

for century, group in df.groupby('first_century'):
    plt.plot(group['period'], group['pct_retained'], label=f'{century}th Century')

plt.title('Retenção por Período para Cada Século')
plt.xlabel('Período')
plt.ylabel('Proporção Retida')
plt.legend(title='Século')
plt.grid(False)
plt.tight_layout()

# Configurações Extras
ax = plt.gca()
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)

plt.show()
