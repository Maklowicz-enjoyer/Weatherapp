import React from 'react';
import ReactDOM from 'react-dom';

const baseURL = '';

const getWeatherFromApi = async () => {
  try {
    console.log('Fetching weather from:', `/api/weather`);
    const response = await fetch(`/api/weather`);
    const data = await response.json();
    console.log('Weather data:', data);
    return data;
  } catch (error) {
    console.error('Error fetching weather:', error);
    return {};
  }
};

class Weather extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      icon: "",
      loading: true,
      error: null
    };
  }

  async componentDidMount() {
    try {
      const weather = await getWeatherFromApi();
      if (weather && weather.icon) {
        this.setState({
          icon: weather.icon.slice(0, -1),
          loading: false
        });
      } else {
        this.setState({
          error: 'No weather data received',
          loading: false
        });
      }
    } catch (error) {
      this.setState({
        error: error.message,
        loading: false
      });
    }
  }

  render() {
    const { icon, loading, error } = this.state;

    if (loading) {
      return <div>Loading weather...</div>;
    }

    if (error) {
      return <div>Error: {error}</div>;
    }

    return (
      <div className="icon">
        { icon && <img src={`/img/${icon}.svg`} alt="Weather icon" /> }
        { !icon && <div>No weather icon available</div> }
      </div>
    );
  }
}

ReactDOM.render(
  <Weather />,
  document.getElementById('app')
);
