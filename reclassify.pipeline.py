import numpy as np

def reclassify_bldg(ins,outs):
	coplanar = ins['Coplanar']
	rank     = ins['Rank']
	hag      = ins['HeightAboveGround']
	cls      = ins['Classification']

	outs['Classification'] = np.where(
		np.logical_and(
			cls == 1,
			np.logical_and(
				hag >= 2,
				np.logical_or(
					coplanar == 1,
					rank == 2
				)
			)
		),
		6,
		cls
	)

	return True

def reclassify_veg(ins, outs):
	nreturn  = ins['ReturnNumber']
	nreturns = ins['NumberOfReturns']
	coplanar = ins['Coplanar']
	rank     = ins['Rank']
	hag      = ins['HeightAboveGround']
	cls      = ins['Classification']

	cls = np.where(
		np.logical_and(
			cls == 1,
			np.logical_and(hag >= 0, hag < 2)
		),
		3, cls
	)

	cls = np.where(
		np.logical_and(
			cls == 1,
			np.logical_and(hag >= 2, hag < 10)
		),
		4, cls
	)

	outs['Classification'] = np.where(
		np.logical_and(
			cls == 1,
			hag >= 10
		),
		5, cls
	)

	return True
