/* reposyd-reportblock-header */
const Diagrams = require( 'reposyd-core' ).ReportFramework.Diagrams
const LexicographicalOrder = require( 'reposyd-core' ).Utils.LexicographicalOrder
const ReportBlock = require( 'reposyd-core' ).ReportFramework.ReportBlock
const ReportTable = require( 'reposyd-core' ).ReportFramework.ReportTable
const Rule = require( 'js-rules-engine' ).Rule
const Utils = require( 'reposyd-core' ).Utils
/* reposyd-reportblock-header */
class ReportBlockFunctionalBreakdown extends ReportBlock {
  constructor( section, engine ) {
    super( section, engine )
    /* reposyd-reportblock-constructor */
    this.sectionNumber = new Utils.LexicographicalOrder.SectionNumber( this.section.number )
    /* reposyd-reportblock-constructor */
  }
  /* reposyd-reportblock-body */
  renderContent() {
    const self = this
    this.format.writeHtml( this.section.text )

    const fn = this.designData.designDataObject( this.section.reportblock.options.reportblock.startingpoint )
    if ( !fn ) {

    } else {
      self.sectionNumber.add()
      followBreakdown( fn )
    }

    function followBreakdown( fn ) {
      self.addSection( self.sectionNumber.toString(), fn.attributes.title )
      self.designData.modeling.object.diagrams(fn.uuid, self.section.reportblock.options.reportblock.diagramtype).forEach(dm => {
        self.writeDiagram( dm )
      })
      self.writeHtml( fn.attributes.description, 'description' )

      self.sectionNumber.add()
      self.designData.designDataLinks( fn, 'dividedinto', 'FN' ).forEach( item => {
        followBreakdown(item.ddo)
      } )

      self.sectionNumber.remove()
      
      self.sectionNumber.inc()
    }
  }
  /* reposyd-reportblock-body */
  static RuleDefinition( settings ) {
    var rule = ReportBlockRequirements.DefaultSettings( settings ).rule;
    return rule === undefined ? null : rule
  }
  static DefaultSettings( settings ) {
    return {
      /* reposyd-reportblock-settings */
      section: [{
        id: 'pageBreak',
        title: {
          'de-DE': 'Seitenumbruch',
          'en-US': 'Page Break'
        },
        type: 'boolean',
        value: false
      }],
      reportblock: [
        {
          id: 'startingpoint',
          title: {
            'de-DE': 'Startpunkt',
            'en-US': 'Starting point'
          },
          type: 'select',
          options: 'FN',
          selection: 'single',
          value: 'none'
        },
        {
          id: 'diagramtype',
          title: {
            'de-DE': 'Diagramart',
            'en-US': 'Diagram type'
          },
          type: 'select',
          options: [
            { label: 'common.none', value: 'none' },
            { label: 'common.actd', value: 'actd' }
          ],
          selection: 'single',
          value: 'none'
        }
      ]
    }
    /* reposyd-reportblock-settings */
  }
}

module.exports = ReportBlockFunctionalBreakdown
