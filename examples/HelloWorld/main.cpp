#include <SDL2/SDL.h>
#include <factoryCraft/foo.h>

/************************************************************************************
 * Definition
 ***********************************************************************************/

/////////////////////////
//        System       //
/////////////////////////

constexpr int system_window_width = 800;
constexpr int system_window_height = 600;

struct System
{
  SDL_Window * window = nullptr;
  SDL_Renderer* renderer = nullptr;
};

bool System_create(struct System* system);
void System_destroy(struct System* system);

/************************************************************************************
 ************************************************************************************
 *                                 Implementation
 ************************************************************************************
 ***********************************************************************************/

/////////////////////////
//        System       //
/////////////////////////

bool System_create(struct System* system)
{
  int error = SDL_Init(SDL_INIT_VIDEO);
  if(error != 0)
  {
    return false;
  }

  system->window = SDL_CreateWindow("SDL2 Pixel Drawing",
    SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
    system_window_width, system_window_height,
    0);

  system->renderer = SDL_CreateRenderer(system->window,
    -1,
    SDL_RENDERER_ACCELERATED |
      SDL_RENDERER_PRESENTVSYNC);

  return true;
}

void System_destroy(struct System* system)
{
  SDL_DestroyRenderer(system->renderer);
  SDL_DestroyWindow(system->window);
  SDL_Quit();
}

/////////////////////////
//        Main         //
/////////////////////////

int main()
{
  struct System system;

  factoryCraft::foo(0);

  if(!System_create(&system)){
    return 1;
  }

  bool running = true;
  while(running)
  {
    SDL_Event event;
    SDL_WaitEvent(&event);
    switch (event.type)
    {
    case SDL_QUIT:
      running = false;
      break;
    default:
      break;
    }

    constexpr Uint8 clear_red = 100;
    constexpr Uint8 clear_green = 100;
    constexpr Uint8 clear_blue = 100;
    constexpr Uint8 clear_alpha = 255;

    SDL_SetRenderDrawColor(system.renderer, clear_red, clear_green, clear_blue, clear_alpha);
    SDL_RenderClear(system.renderer);

    SDL_RenderPresent(system.renderer);
  }

  System_destroy(&system);
  return 0;
}
