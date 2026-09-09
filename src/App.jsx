import './App.css'

function App() {
  // El hash (#propiedades, #clientes, #comisiones) vive en la URL de la
  // ventana de arriba; se lo pasamos al iframe como su propio hash para
  // que PropTrack.dc.html pueda leerlo y abrir esa pantalla directo.
  const src = '/PropTrack.dc.html' + window.location.hash

  return (
    <iframe
      className="prototype-frame"
      src={src}
      title="PropTrack"
    />
  )
}

export default App
