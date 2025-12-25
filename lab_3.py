import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation

class ParticleSwarmOptimization:
    def __init__(self, objective_func, bounds, num_particles=50, max_iter=100, 
                 w=0.5, c1=1.5, c2=1.5):
        """
        Инициализация алгоритма PSO
        
        Parameters:
        -----------
        objective_func : function
            Целевая функция для минимизации
        bounds : list of tuples
            Границы поиска для каждой размерности [(min, max), ...]
        num_particles : int
            Количество частиц в рое
        max_iter : int
            Максимальное количество итераций
        w : float
            Инерционный вес
        c1, c2 : float
            Коэффициенты ускорения (познавательный и социальный)
        """
        self.objective_func = objective_func
        self.bounds = np.array(bounds)
        self.num_particles = num_particles
        self.max_iter = max_iter
        self.w = w
        self.c1 = c1
        self.c2 = c2
        
        self.dimensions = len(bounds)
        self.global_best_position = None
        self.global_best_value = float('inf')
        
        # История для визуализации
        self.history = {
            'positions': [],
            'best_positions': [],
            'global_best_values': []
        }
        
        self._initialize_particles()
    
    def _initialize_particles(self):
        """Инициализация частиц"""
        # Инициализация позиций частиц
        self.positions = np.random.uniform(
            self.bounds[:, 0], 
            self.bounds[:, 1], 
            (self.num_particles, self.dimensions)
        )
        
        # Инициализация скоростей
        self.velocities = np.zeros((self.num_particles, self.dimensions))
        
        # Лучшие позиции частиц (персональные лучшие)
        self.personal_best_positions = self.positions.copy()
        self.personal_best_values = np.array([
            self.objective_func(pos) for pos in self.positions
        ])
        
        # Обновление глобального лучшего
        min_idx = np.argmin(self.personal_best_values)
        if self.personal_best_values[min_idx] < self.global_best_value:
            self.global_best_value = self.personal_best_values[min_idx]
            self.global_best_position = self.personal_best_positions[min_idx].copy()
    
    def _update_velocity(self, i):
        """Обновление скорости для i-й частицы"""
        r1, r2 = np.random.rand(self.dimensions), np.random.rand(self.dimensions)
        
        cognitive_velocity = self.c1 * r1 * (self.personal_best_positions[i] - self.positions[i])
        social_velocity = self.c2 * r2 * (self.global_best_position - self.positions[i])
        
        self.velocities[i] = (
            self.w * self.velocities[i] + 
            cognitive_velocity + 
            social_velocity
        )
    
    def _update_position(self, i):
        """Обновление позиции для i-й частицы"""
        self.positions[i] += self.velocities[i]
        
        # Ограничение позиций границами поиска
        for d in range(self.dimensions):
            if self.positions[i, d] < self.bounds[d, 0]:
                self.positions[i, d] = self.bounds[d, 0]
                self.velocities[i, d] *= -0.5  # Отскок от границы
            elif self.positions[i, d] > self.bounds[d, 1]:
                self.positions[i, d] = self.bounds[d, 1]
                self.velocities[i, d] *= -0.5
    
    def optimize(self, verbose=True):
        """
        Запуск оптимизации
        
        Returns:
        --------
        global_best_position : ndarray
            Найденное оптимальное решение
        global_best_value : float
            Значение целевой функции в оптимальной точке
        """
        for iteration in range(self.max_iter):
            for i in range(self.num_particles):
                # Оценка текущей позиции
                current_value = self.objective_func(self.positions[i])
                
                # Обновление персонального лучшего
                if current_value < self.personal_best_values[i]:
                    self.personal_best_values[i] = current_value
                    self.personal_best_positions[i] = self.positions[i].copy()
                    
                    # Обновление глобального лучшего
                    if current_value < self.global_best_value:
                        self.global_best_value = current_value
                        self.global_best_position = self.positions[i].copy()
                
                # Обновление скорости и позиции
                self._update_velocity(i)
                self._update_position(i)
            
            # Сохранение истории
            self.history['positions'].append(self.positions.copy())
            self.history['best_positions'].append(self.personal_best_positions.copy())
            self.history['global_best_values'].append(self.global_best_value)
            
            if verbose and (iteration + 1) % 10 == 0:
                print(f"Iteration {iteration + 1}/{self.max_iter}, "
                      f"Best value: {self.global_best_value:.6f}")
        
        return self.global_best_position, self.global_best_value
    
    def plot_convergence(self):
        """Визуализация сходимости алгоритма"""
        fig, axes = plt.subplots(1, 2, figsize=(15, 5))
        
        # График сходимости
        axes[0].plot(self.history['global_best_values'])
        axes[0].set_xlabel('Iteration')
        axes[0].set_ylabel('Best Value')
        axes[0].set_title('Convergence Plot')
        axes[0].grid(True, alpha=0.3)
        
        # Траектории частиц (для 2D задач)
        if self.dimensions == 2:
            positions_history = np.array(self.history['positions'])
            for i in range(min(self.num_particles, 20)):  # Показываем только 20 частиц
                axes[1].plot(positions_history[:, i, 0], positions_history[:, i, 1], 
                            alpha=0.3, linewidth=0.5)
            
            # Отметить начальные и конечные позиции
            axes[1].scatter(positions_history[0, :, 0], positions_history[0, :, 1], 
                           c='blue', s=30, label='Start', alpha=0.6)
            axes[1].scatter(positions_history[-1, :, 0], positions_history[-1, :, 1], 
                           c='red', s=30, label='End', alpha=0.6)
            axes[1].scatter(self.global_best_position[0], self.global_best_position[1], 
                           c='green', s=100, marker='*', label='Global Best')
            
            axes[1].set_xlabel('X')
            axes[1].set_ylabel('Y')
            axes[1].set_title('Particle Trajectories')
            axes[1].legend()
            axes[1].grid(True, alpha=0.3)
        
        plt.tight_layout()
        plt.show()


def rastrigin_function(x):
    """
    Функция Растригина
    Глобальный минимум: f(0,0,...,0) = 0
    """
    A = 10
    return A * len(x) + sum([(xi**2 - A * np.cos(2 * np.pi * xi)) for xi in x])

# Настройки
bounds = [(-5.12, 5.12), (-5.12, 5.12)]  # 2D пространство поиска
pso = ParticleSwarmOptimization(
    objective_func=rastrigin_function,
    bounds=bounds,
    num_particles=30,
    max_iter=100,
    w=0.7,
    c1=1.5,
    c2=1.5
)

# Запуск оптимизации
best_position, best_value = pso.optimize()
print(f"\nOptimal solution: {best_position}")
print(f"Optimal value: {best_value}")

# Визуализация
pso.plot_convergence()



def sphere_function(x):
    """
    Сферическая функция
    Глобальный минимум: f(0,0,...,0) = 0
    """
    return sum([xi**2 for xi in x])

def rosenbrock_function(x):
    """
    Функция Розенброка (банановая функция)
    Глобальный минимум: f(1,1,...,1) = 0
    """
    return sum([100 * (x[i+1] - x[i]**2)**2 + (1 - x[i])**2 
                for i in range(len(x)-1)])

# Тестирование разных функций
test_functions = [
    ("Sphere", sphere_function, [(-10, 10), (-10, 10)]),
    ("Rastrigin", rastrigin_function, [(-5.12, 5.12), (-5.12, 5.12)]),
    ("Rosenbrock", rosenbrock_function, [(-2, 2), (-1, 3)])
]

results = {}
for name, func, bounds in test_functions:
    print(f"\n{'='*50}")
    print(f"Optimizing {name} function")
    print('='*50)
    
    pso = ParticleSwarmOptimization(
        objective_func=func,
        bounds=bounds,
        num_particles=40,
        max_iter=50,
        w=0.5,
        c1=2.0,
        c2=2.0
    )
    
    best_pos, best_val = pso.optimize(verbose=False)
    results[name] = (best_pos, best_val)
    
    print(f"Best position: {best_pos}")
    print(f"Best value: {best_val:.6f}")