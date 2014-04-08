# set the scene size
WIDTH = window.innerWidth-10
HEIGHT = window.innerHeight-10

# set some camera attributes
VIEW_ANGLE = 45
ASPECT = WIDTH / HEIGHT
NEAR = 0.1
FAR = 10000

rulePair = [150,60]
simulationTime = 15
maxTime = 40

sceneObjects = null

initialPattern = "#"
animationStop = false

# get the DOM element to attach to
# - assume we've got jQuery to hand
$container = document.getElementById "container"

# create a WebGL renderer, camera
# and a scene
renderer = if Detector.webgl then new THREE.WebGLRenderer() else new THREE.CanvasRenderer()
camera = new THREE.PerspectiveCamera(VIEW_ANGLE, ASPECT, NEAR, FAR)
scene = new THREE.Scene()

# Automata, known to Wolfram site.
wolfram_automata = {30:1, 50:1; 54:1; 60:1; 62:1; 90:1; 94:1; 102:1; 110:1; 126:1; 150:1; 158:1; 182:1; 188:1; 190:1; 220:1; 222:1}

# add the camera to the scene
scene.add camera

camera.position.set -14, -40, -60
camera.lookAt scene

#attaches fly controls to the camera
controls=null

# start the renderer
renderer.setSize WIDTH, HEIGHT

# attach the render-supplied DOM element
$container.appendChild renderer.domElement

# create the cells's material
#

cellMaterial =[
  new THREE.MeshLambertMaterial(color: 0x9eff5f),
  new THREE.MeshLambertMaterial(color: 0xf68241),
  new THREE.MeshLambertMaterial(color: 0x5facff),
  new THREE.MeshLambertMaterial(color: 0xeaeaea)]

#cellMaterial = new THREE.MeshLambertMaterial( map: cubeTexture)
cubeSize = 1.0
cellGeometry = new THREE.CubeGeometry cubeSize, cubeSize, cubeSize
#cellGeometry = new THREE.SphereGeometry cubeSize*0.5, 8, 6

# Return list of cell meshes.
createWorldMesh = (worldState) ->
  #geom = new THREE.SphereGeometry radius, segments, rings
  stringGeometry = new THREE.Geometry()
  for wi, i in worldState
    continue  unless wi
    cell = new THREE.Mesh cellGeometry
    cell.position.x = i - worldState.length * 0.5
    THREE.GeometryUtils.merge stringGeometry, cell
  return stringGeometry

# create a point light
putCamLight = (color, intens, x, y, z) ->
  pointLight = new THREE.PointLight color, intens
  pointLight.position.set x,y,z
  scene.add pointLight

###
  geom = new THREE.SphereGeometry 0.5, 6, 6
  mesh = new THREE.Mesh geom, new THREE.MeshLambertMaterial(color: color)
  mesh.position.set x,y,z
  scene.add mesh
###

putCamLight 0xf0fff0, 0.7, -60, 60, -30
putCamLight 0xf0f0ff, 0.7, 60, 60, -30
putCamLight 0xfff0f0, 0.7, 0, -28, -30

putCamLight 0xffeeee, 0.2, 0, 0, 90

putCamLight 0xffffff, 0.2, 0, 0, 0

# SKYBOX/FOG
skyBoxGeometry = new THREE.CubeGeometry( 10000, 10000, 10000 );
#cubeTexture = THREE.ImageUtils.loadTexture('./images/box-texture.png');

spriteTextures =
  t1: THREE.ImageUtils.loadTexture './images/sprite-t1.png'
  t2: THREE.ImageUtils.loadTexture './images/sprite-t2.png'
  x : THREE.ImageUtils.loadTexture './images/sprite-x.png'

skyBoxMaterial = new THREE.MeshBasicMaterial
  #map: cubeTexture
  color: 0x333333
  side: THREE.BackSide
skyBox = new THREE.Mesh skyBoxGeometry, skyBoxMaterial
scene.add skyBox

#scene.fog = new THREE.FogExp2( 0x9999ff, 0.01 );

#----Update----//
update = ->
  if animationStop
    animationStop = false
    return
  #update controls
  controls.update() #1 for orbit
    
  #call draw
  renderer.render scene, camera
  
  #requests the browser to call update at it's own pace
  requestAnimationFrame update
  

createAxes = (len) ->
  stemMaterial = new THREE.MeshBasicMaterial(color: 0xFFFFFF)
  pointerMaterial = new THREE.MeshBasicMaterial(color: 0x00FF00)

  stemRadius = 0.05

  makeArrow = (len, label) ->
    stemG = new THREE.CylinderGeometry stemRadius, stemRadius, len, 4, 1
    stemG.applyMatrix (new THREE.Matrix4()).makeTranslation(0, len/2, 0)

    pointerG = new THREE.CylinderGeometry 0, stemRadius*4, 1, 32, 2
    stem = new THREE.Mesh stemG, stemMaterial
    pointer = new THREE.Mesh pointerG, pointerMaterial
    pointer.position.y = len
    stem.add pointer

    lbl = makeTextureSprite spriteTextures[label]
    lbl.position.set 0, len+2, 0
    lbl.scale.set 2, 2, 2
    stem.add lbl
    
    stem

  axes = new THREE.Object3D()

  arrow = makeArrow len, 't1'
  arrow.rotation.x = 0
  axes.add arrow

  arrow = makeArrow len, "t2"
  arrow.rotation.x = Math.PI/2
  axes.add arrow
  
  arrow = makeArrow len*2, "x"
  arrow.position.x = len
  arrow.rotation.z = Math.PI/2
  axes.add arrow

  axes.position.set -0.5, -1, -1
  return axes
        
createWorldEvolutionMesh = (world, index1, index2, time) ->
  worldGeometry = [ new THREE.Geometry(),  new THREE.Geometry(), new THREE.Geometry(), new THREE.Geometry() ]
  automaton = index2table index1
  automaton2 = index2table index2  
  w = world
  for t in [0 ... time] by 1
    wt = w
    for t1 in [0 ... time] by 1
      geomIdx = (t>0)*1 + (t1>0)*2
      stringMesh = new THREE.Mesh createWorldMesh wt
      stringMesh.position.set 0, t, t1
      THREE.GeometryUtils.merge worldGeometry[geomIdx], stringMesh
      wt = tfm_circular wt, automaton2
    w = tfm_circular(w, automaton)

  worldObj = new THREE.Object3D()
  for g, i in worldGeometry
    worldObj.add new THREE.Mesh(g, cellMaterial[i] )
    
  return worldObj

makeTextureSprite = (texture) -> 
  # canvas contents will be used for a texture
  spriteMaterial = new THREE.SpriteMaterial(
    map: texture
    useScreenCoordinates: false
    #alignment: spriteAlignment
  )
  sprite = new THREE.Sprite spriteMaterial
  #sprite.scale.set 1, 0.5, 1.0
  sprite
 
showSettings = ->
  container = document.getElementById "settings"
  container.style.display = "block"
  animationStop = true
  document.getElementById("simulation-time").value = simulationTime

closeSettings = () ->
  container = document.getElementById "settings"
  container.style.display = "none"
  t = parseInt document.getElementById("simulation-time").value, 10
  unless isNaN t
    simulationTime = Math.min(maxTime, Math.max(1, t))
      
  updateWorld()
  update()

updateWorld = () ->
  #Initial world state
  world = (0 for _ in [0...(simulationTime * 4 + initialPattern.length)])
  putPatternAtCenter world, initialPattern
  time = simulationTime
  if sceneObjects isnt null
    scene.remove sceneObjects
  sceneObjects = new THREE.Object3D()
  sceneObjects.add createWorldEvolutionMesh world, rulePair[0], rulePair[1], time, time
  sceneObjects.add createAxes time+3

  sceneObjects.position.set -time*0.5, -time*0.5, -time*0.5
  scene.add sceneObjects
  return sceneObjects  

window.initApplication = ->
  document.getElementById("show-settings").onclick = -> showSettings()
  document.getElementById("settings").onclick = -> closeSettings()
  document.getElementById("close-settings").onclick = -> closeSettings()
  document.getElementById("settings-inner").onclick = (e)->e.stopPropagation()

  patternEdit = document.getElementById("initial-pattern-text")
  patternEdit.value =  initialPattern
  window.addEventListener 'resize', onWindowResize, false

  rule1Selector = new RuleSelector "rule1-select-graph", "rule1-diagram", "rule1-text", "rule1-info", rulePair[0]
  rule2Selector = new RuleSelector "rule2-select-graph", "rule2-diagram", "rule2-text", "rule2-info", rulePair[1], rulePair[0]

  patternEdit.onchange = (e)->
    newPattern = patternEdit.value
    initialPattern = newPattern
    rule1Selector.drawEvolution()
    rule2Selector.drawEvolution()
  
  rule2Selector.onrule = (rule) ->
    rulePair[1] = rule
  rule1Selector.onrule = (rule) ->
    rulePair[0] = rule
    rule2Selector.setCompatibileWith rule


  #THREEx.WindowResize renderer, camera    
  initScene()

putPatternAtCenter = (world, pattern)->
  worldCenter = world.length/2|0
  patternCenter = pattern.length/2|0
  for i in [0...pattern.length] by 1
    if pattern.charAt(i) is '#'
      world[i - patternCenter + worldCenter] = 1
      

class RuleSelector
  constructor: (diagramId, displayId, textFieldId, infoFieldId, @selectedRule=0, @compatibleWith = null)->
    @iconSize = 8
    @diagramCanvas = document.getElementById diagramId
    @diagramContext = @diagramCanvas.getContext "2d"
    
    displayCanvas = document.getElementById displayId
    @displayContext = displayCanvas.getContext "2d"
    
    @textField = document.getElementById textFieldId
    @infoField = document.getElementById infoFieldId
    @textField.value = @selectedRule
    @diagramCanvas.onclick = (event)=>@onCanvasClick(event)
    @draw()
    @drawEvolution()
    @textField.onchange = (e)=>
      newVal = parseInt @textField.value, 10
      if newVal >=0 and newVal <=255 and (newVal%2 is 0)
        if @acceptRule newVal
          @setSelected newVal
        else
          @showErrorMessage "Rule #{newVal} is not compatible with the first rule"
      else
        @showErrorMessage "Rule code must be even number in range [0 .. 254]"
        
          
  showWolfrawmUrl: ->
    @infoField.innerHTML = ""
    atag = document.createElement "a"
    atag.setAttribute "href", "http://mathworld.wolfram.com/Rule#{@selectedRule}.html"
    atag.setAttribute "target", "_blanc"
    atag.appendChild document.createTextNode "Rule#{@selectedRule}"
    @infoField.appendChild document.createTextNode "Wolfram: "
    @infoField.appendChild atag
    @infoField.style.display = "block"

  showErrorMessage: (msg)->
    @infoField.innerHTML = ""
    span = document.createElement "span"
    span.setAttribute "class", "error-text"
    span.appendChild document.createTextNode msg
    @infoField.appendChild span
    @infoField.style.display = "block"
    
  hideInfo: ->
    @infoField.innerHTML = ""
    @infoField.style.display = "hidden"
    
  setSelected: (newRule) ->
    if newRule isnt @selectedRule
      @selectedRule = newRule
      @clearDiagram()
      @draw()
      @drawEvolution()
      @onrule newRule
      if wolfram_automata[newRule]
        @showWolfrawmUrl()
      else
        @hideInfo()
      
  acceptRule: (rule) ->
    if @compatibleWith is null
      true
    else
      areRulesCompatible @compatibleWith, rule
      
  draw: ->
    ctx = @diagramContext
    iconSize = @iconSize
    xsel = null
    for y in [0...8]
      for x in [0...16]
        idx = @cell2rule x, y
        if idx == @selectedRule
          xsel = x
          ysel = y
        if @acceptRule idx
          @drawRuleIcon ctx, idx, x * iconSize, y * iconSize, iconSize
    if xsel isnt null
      ctx.strokeStyle = "#ff0000"
      ctx.strokeRect xsel * iconSize - .5, ysel * iconSize - .5, iconSize+1,iconSize+1
    return
    
  drawEvolution: ->
    ctx = @displayContext
    size = 2 #px
    steps = 32
    world = (0 for _ in [0...64])
    automaton = index2table @selectedRule
    #alert "Drawing evoluion for #{@selectedRule}"
    putPatternAtCenter world, initialPattern
    ctx.clearRect 0,0,world.length*size,steps*size
    ctx.fillStyle = "black"
    y = 0
    while true
      for wi, x in world
        if wi isnt 0
          ctx.fillRect x*size, y*size, size, size
      y++
      if y >= 32
        break
      world = tfm_circular world, automaton
    return
      
      
  cell2rule: (ix, iy) -> ix * 16 + iy * 2

  drawShadedRuleIcon: (ctx, rule, x, y, size) ->
    ctx.fillStyle = "gray"
    ctx.fillRect x, y, size, size

  colors: [
    new THREE.Color(0x00a1ff),
    new THREE.Color(0x1f2f1f)]
  
  numDuals2Color: (nduals) ->
    t = (nduals - 3)/(15-3)
    t = Math.min(Math.max(0.0,t),1.0)
    cs = @colors
    clr = cs[1].clone().lerp(cs[0], t)
    "#"+clr.getHexString()

  drawRuleIcon: (ctx, rule, x, y, size) ->
    props = RULE_PROPERTIES[rule.toString(16)]
    hasFlag = (propChar) -> props.flags.indexOf(propChar) isnt -1
    mirror = parseInt props.mirror, 16

  
    ctx.fillStyle = @numDuals2Color parseInt(props.nduals,16)    
    ctx.fillRect x, y, size, size

    ctx.strokeStyle = 
      if mirror < rule
        "white"
      else
        "yellow"
        
    if hasFlag "|"
      ctx.beginPath()
      ctx.moveTo x+1, y+size-1
      ctx.lineTo x+size*0.5, y+1
      ctx.lineTo x+size-1, y+size-1
      ctx.stroke()
    if hasFlag "&"
      ctx.beginPath()
      ctx.moveTo x+1, y+1
      ctx.lineTo x+size*0.5, y+size-1
      ctx.lineTo x+size-1, y+1
      ctx.stroke()
    if hasFlag "^"
      ctx.beginPath()
      ctx.moveTo x+1, y+size*0.5
      ctx.lineTo x+size-1, y+size*0.5
      ctx.moveTo x+size*0.5, y+1
      ctx.lineTo x+size*0.5, y+size-1
      ctx.stroke()
    if wolfram_automata[rule]
      ctx.strokeStyle = "green"
      ctx.strokeRect x+0.5, y+0.5, size-1, size-1
    return    
        
  onCanvasClick: (event)->
    [x,y] = getCanvasCursorPosition event, @diagramCanvas
    ix = (x/@iconSize) | 0
    iy = (y/@iconSize) | 0
    if not (ix<0 or ix>=16 or iy <0 or iy >=8)
      event.preventDefault()
      rule = @cell2rule ix,iy
      return unless @acceptRule rule
      @setSelected rule
      @textField.value = rule
      
  setCompatibileWith: (rule) ->
    @compatibleWith = rule
    @clearDiagram()
    @draw()
    
  clearDiagram: -> @diagramContext.clearRect 0,0,16*@iconSize,8*@iconSize
  onrule: (rule) ->

initScene = ->

  updateWorld()

  # Add OrbitControls so that we can pan around with the mouse.
  #controls = new THREE.OrbitControls camera, renderer.domElement
  if true #trackball controls
    controls = new THREE.TrackballControls camera, renderer.domElement
    controls.rotateSpeed = 2.0;
    controls.zoomSpeed = 1.2;
    controls.panSpeed = 0.8;
  
    controls.noZoom = false;
    controls.noPan = false;

    controls.staticMoving = true;
    controls.dynamicDampingFactor = 0.3;
    controls.keys = [ 65, 83, 68 ];

  
  update()



onWindowResize = ->
  WIDTH = window.innerWidth - 10
  HEIGHT = window.innerHeight - 10
  camera.aspect = WIDTH / HEIGHT
  camera.updateProjectionMatrix()  
  renderer.setSize WIDTH, HEIGHT
  controls.handleResize()
  render()


areRulesCompatible = (rule1, rule2) ->
  if rule2 < rule1
    areRulesCompatible rule2, rule1
  else if rule2 is rule1
    true
  else
    if (map = RULES_COMPATIBILITY_MAP[rule1.toString(16)])?
      (rule2.toString(16)) of map
    else
      false

getCanvasCursorPosition = (e, canvas) ->
  if e.type is "touchmove" or e.type is "touchstart" or e.type is "touchend"
    e=e.touches[0]
  if e.clientX?
    rect = canvas.getBoundingClientRect()
    return [e.clientX - rect.left, e.clientY - rect.top]
