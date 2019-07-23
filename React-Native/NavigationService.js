import { NavigationActions, StackActions } from 'react-navigation'

export const ScreenConstants = {
  HomeScreen: { name: 'HomeScreen', title: 'Home' },
  LogInScreen: { name: 'LogInScreen', title: 'Login' },
  SignUpScreen: { name: 'SignUpScreen', title: 'Sign Up' },
  DevicesScreen: { name: 'DevicesScreen', title: 'Devices' },
  SearchDevicesScreen: { name: 'SearchDevicesScreen', title: 'Search devices' },
  ProfileScreen: {name: 'ProfileScreen', title: 'Profile',},
  WifiListScreen: {name: 'WifiListScreen', title: 'Wifi List'},
  DeviceSettingsScreen: {name: 'DeviceSettingsScreen', title: 'Device Settings'},
  GreenModeDeviceSettingsScreen: {name: 'GreenModeDeviceSettingsScreen', title: ''},
  TimingSettingsScreen: {name: 'TimingSettingsScreen', title: 'Timing'},
  TimingListScreen: {name: 'TimingListScreen', title: 'Timing List'},
};

let navigator

function setTopLevelNavigator(navigatorRef) {
  navigator = navigatorRef
}

function navigate(routeName, params) {
  navigator.dispatch(
    NavigationActions.navigate({
      routeName,
      params,
    })
  )
}

function goBack() {
  navigator.dispatch(NavigationActions.back())
}

function navigateAndReset(routeName, params) {
  navigator.dispatch(
    StackActions.reset({
      index: 0,
      key: null,
      actions: [
        NavigationActions.navigate({
          routeName,
          params,
        }),
      ],
    })
  )
}

export default {
  goBack,
  navigate,
  navigateAndReset,
  setTopLevelNavigator,
}
