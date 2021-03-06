import gym
from gym import error, spaces, utils
from gym.utils import seeding
from helper_functions_python import *
from gym.spaces import Dict


class MairioEnv(gym.Env):

    def __init__(self):
        metadata = {'render.modes': ['human'],"disable_env_checker":True}

        self.action_space = spaces.Discrete(256)
        print(self.action_space)
        self.observation_space = spaces.Box(
            low=-1, high=24, shape=([14, 16]), dtype=np.uint8)
        #print(1,self.action_space.low, self.action_space.high)
        self.inputs = {"A": False,
                       "B": False,
                       "Y": False,
                       "X": False,
                       "Left": False,
                       "Right": False,
                       "Up": False,
                       "Down": False}
        self.state = None
        self.reward = 0
        self.reset_flag = 0
        initialize()

    def step(self, action: dict):
        write_inputs_to_file("Code/data/inputs", action)
        wait_for_lua()
        self.state = get_data_grid()
        self.reward = get_reward()
        self.reset_flag = check_for_reset()
        return self.state, self.reward, self.reset_flag

    def reset(self):
        self.inputs = {"A": False,
                       "B": False,
                       "Y": False,
                       "X": False,
                       "Left": False,
                       "Right": False,
                       "Up": False,
                       "Down": False}
        self.state = np.full((14, 16), 0, dtype=np.uint8)
        self.reward = 0
        self.reset_flag = 0
        return self.state

    def render(self, mode='human', close=False):
        grid = get_data_grid()
        # print(grid.shape)

        obj = plt.imshow(grid)
        plt.draw()
