#pragma once

namespace stdext {

static int fastrand()
{
    static int g_seed = (214013 + 2531011);
    g_seed = (214013 * g_seed + 2531011);
    return (g_seed >> 16) & 0x7FFF;
};

}